// Basic traceroute utility
// DNS resolver and ICMP packet size are configurable
// Build then run as sudo
//
// Instructions:
// go mod init example.com/gotrace
// go mod tidy
// go build gotrace.go
// sudo ./gotrace theregister.co.uk

package main

import (
	"fmt"
	"net"
	"os"
	"time"

	"golang.org/x/net/icmp"
	"golang.org/x/net/ipv4"
)

const (
	defaultResolver   = "8.8.8.8" // Default DNS resolver
	defaultPacketSize = 512       // Default ICMP packet size in bytes
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: gotrace <target>")
		os.Exit(1)
	}

	target := os.Args[1]
	ipAddr, err := resolveHostname(target)
	if err != nil {
		fmt.Printf("Error resolving hostname: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Traceroute to %s (%s):\n", target, ipAddr)

	for ttl := 1; ttl <= 30; ttl++ {
		// Create an ICMP connection
		conn, err := icmp.ListenPacket("ip4:icmp", "0.0.0.0")
		if err != nil {
			fmt.Printf("Error creating ICMP connection: %v\n", err)
			os.Exit(1)
		}
		defer conn.Close()

		// Set TTL for the packet
		conn.IPv4PacketConn().SetTTL(ttl)

		// Create an ICMP Echo request
		msg := icmp.Message{
			Type: ipv4.ICMPTypeEcho,
			Code: 0,
			Body: &icmp.Echo{
				ID:   os.Getpid() & 0xffff,
				Seq:  ttl,
				Data: []byte("traceroute"),
			},
		}
		msgBytes, err := msg.Marshal(nil)
		if err != nil {
			fmt.Printf("Error marshaling ICMP message: %v\n", err)
			os.Exit(1)
		}

		// Send the ICMP packet
		startTime := time.Now()
		_, err = conn.WriteTo(msgBytes, &net.IPAddr{IP: ipAddr})
		if err != nil {
			fmt.Printf("Error sending ICMP packet: %v\n", err)
			os.Exit(1)
		}

		// Receive the ICMP reply
		reply := make([]byte, 1500)
		_, _, err = conn.ReadFrom(reply)
		if err != nil {
			fmt.Printf("Error receiving ICMP reply: %v\n", err)
			os.Exit(1)
		}

		// Calculate round-trip time
		rtt := time.Since(startTime).Milliseconds()

		fmt.Printf("%2d. %s (%s) %dms\n", ttl, target, ipAddr, rtt)
	}
}

func resolveHostname(hostname string) (net.IP, error) {
	ipAddr, err := net.ResolveIPAddr("ip", hostname)
	if err != nil {
		// Try resolving using the default resolver
		ipAddr, err = net.ResolveIPAddr("ip", hostname)
		if err != nil {
			return nil, err
		}
	}
	return ipAddr.IP, nil
}
