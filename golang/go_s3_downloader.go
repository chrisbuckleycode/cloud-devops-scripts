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
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run go_s3_downloader.go <bucket_name> or ./s3dl <bucket_name>")
		return
	}

	bucketName := os.Args[1]

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		fmt.Printf("Failed to load AWS SDK config: %v\n", err)
		return
	}

	s3Client := s3.NewFromConfig(cfg)

	files, err := listBucketFiles(context.TODO(), s3Client, bucketName)
	if err != nil {
		fmt.Printf("Failed to retrieve files from S3 bucket: %v\n", err)
		return
	}

	outputPath := "archive.zip" // Output zip file name

	err = ZipFiles(outputPath, files, s3Client, bucketName)
	if err != nil {
		fmt.Printf("Failed to create zip file: %v\n", err)
		return
	}

	fmt.Printf("Zip file '%s' created successfully in the current directory.\n", outputPath)
}

// listBucketFiles retrieves the list of files in the specified S3 bucket.
func listBucketFiles(ctx context.Context, s3Client *s3.Client, bucketName string) ([]string, error) {
	var files []string

	paginator := s3.NewListObjectsV2Paginator(s3Client, &s3.ListObjectsV2Input{
		Bucket: &bucketName,
	})

	for paginator.HasMorePages() {
		output, err := paginator.NextPage(ctx)
		if err != nil {
			return nil, err
		}

		for _, obj := range output.Contents {
			files = append(files, *obj.Key)
		}
	}

	return files, nil
}

// ZipFiles creates a zip file containing the specified files.
func ZipFiles(outputPath string, files []string, s3Client *s3.Client, bucketName string) error {
	zipFile, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer zipFile.Close()

	zipWriter := zip.NewWriter(zipFile)
	defer zipWriter.Close()

	for _, file := range files {
		err = addS3ObjectToZip(zipWriter, s3Client, bucketName, file)
		if err != nil {
			return err
		}
	}

	return nil
}

// addS3ObjectToZip downloads an S3 object and adds it to the specified zip writer.
func addS3ObjectToZip(zipWriter *zip.Writer, s3Client *s3.Client, bucketName, s3Key string) error {
	resp, err := s3Client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: &bucketName,
		Key:    &s3Key,
	})
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	header := &zip.FileHeader{
		Name:   filepath.Base(s3Key),
		Method: zip.Deflate,
	}

	writer, err := zipWriter.CreateHeader(header)
	if err != nil {
		return err
	}

	_, err = io.Copy(writer, resp.Body)
	if err != nil {
		return err
	}

	return nil
}
