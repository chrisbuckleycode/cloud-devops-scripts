// Query a domain's DNS records using Google DNS server (8.8.8.8)
// Uses the library miekg/dns to faciliate direct query to external dns server.
// Not yet validated for TXT and SRV records.
//
// Instructions:
// go mod init example.com/dnslookup
// go mod tidy
// go run dns_lookup.go cnn.com

package main

import (
	"fmt"
	"os"

	"github.com/miekg/dns"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Please provide a domain as a parameter.")
		return
	}

	domain := os.Args[1]
	resolverIP := "8.8.8.8" // Change this IP address to your desired DNS resolver, e.g. Cloudflare 1.1.1.1

	resolver := &dns.Client{Net: "udp"}

	recordTypes := []uint16{
		dns.TypeA,
		dns.TypeAAAA,
		dns.TypeCNAME,
		dns.TypeMX,
		dns.TypeNS,
		dns.TypeTXT,
		dns.TypeSRV,
	}

	for _, recordType := range recordTypes {
		msg := dns.Msg{}
		msg.SetQuestion(dns.Fqdn(domain), recordType)

		res, _, err := resolver.Exchange(&msg, resolverIP+":53")
		if err != nil {
			fmt.Printf("Error looking up %s records for %s: %v\n", dns.TypeToString[recordType], domain, err)
			continue
		}

		fmt.Printf("%s records for %s:\n", dns.TypeToString[recordType], domain)
		for _, answer := range res.Answer {
			fmt.Println(answer.String())
		}
		fmt.Println()
	}
}
