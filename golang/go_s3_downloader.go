// Download files from an S3 bucket and create a local zipfile.
//
// Instructions:
// go mod init example.com/gos3downloader
// go mod tidy
// go run go_s3_downloader.go <bucket_name>
//
// Optional: go build -o s3dl go_s3_downloader.go
// ./s3dl <bucket_name>

package main

import (
	"archive/zip"
	"fmt"
	"os"
	"path/filepath"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run main.go <bucket_name>")
		return
	}

	bucketName := os.Args[1]

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1"), // Update with your desired AWS region
	})
	if err != nil {
		fmt.Printf("Failed to create AWS session: %s\n", err.Error())
		return
	}

	s3Client := s3.New(sess)

	files, err := listBucketFiles(s3Client, bucketName)
	if err != nil {
		fmt.Printf("Failed to retrieve files from S3 bucket: %s\n", err.Error())
		return
	}

	outputPath := "archive.zip" // Output zip file name

	err = ZipFiles(outputPath, files)
	if err != nil {
		fmt.Printf("Failed to create zip file: %s\n", err.Error())
		return
	}

	fmt.Printf("Zip file '%s' created successfully in the current directory.\n", outputPath)
}

// listBucketFiles retrieves the list of files in the specified S3 bucket.
func listBucketFiles(s3Client *s3.S3, bucketName string) ([]string, error) {
	var files []string

	err := s3Client.ListObjectsV2Pages(&s3.ListObjectsV2Input{
		Bucket: aws.String(bucketName),
	}, func(page *s3.ListObjectsV2Output, lastPage bool) bool {
		for _, obj := range page.Contents {
			files = append(files, *obj.Key)
		}
		return true
	})

	if err != nil {
		return nil, err
	}

	return files, nil
}

// ZipFiles creates a zip file containing the specified files.
func ZipFiles(outputPath string, files []string) error {
	zipFile, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer zipFile.Close()

	zipWriter := zip.NewWriter(zipFile)
	defer zipWriter.Close()

	for _, file := range files {
		err = addS3ObjectToZip(zipWriter, file)
		if err != nil {
			return err
		}
	}

	return nil
}

// addS3ObjectToZip downloads an S3 object and adds it to the specified zip writer.
func addS3ObjectToZip(zipWriter *zip.Writer, s3Key string) error {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1"), // Update with your desired AWS region
	})
	if err != nil {
		return err
	}

	downloader := s3.NewDownloader(sess)

	buf := aws.NewWriteAtBuffer([]byte{})

	_, err = downloader.Download(buf, &s3.GetObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(s3Key),
	})
	if err != nil {
		return err
	}

	header, err := zip.FileInfoHeader(&zip.FileHeader{
		Method: zip.Deflate,
	})
	if err != nil {
		return err
	}

	header.Name = filepath.Base(s3Key)

	writer, err := zipWriter.CreateHeader(header)
	if err != nil {
		return err
	}

	_, err = writer.Write(buf.Bytes())
	if err != nil {
		return err
	}

	return nil
}
