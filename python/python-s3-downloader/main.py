import os
import zipfile
import boto3
from datetime import datetime

def list_s3_objects(bucket_name):
    """
    Lists all objects in the specified S3 bucket.
    """
    s3 = boto3.client('s3')
    try:
        response = s3.list_objects_v2(Bucket=bucket_name)
        objects = response.get('Contents', [])
        return [obj['Key'] for obj in objects]
    except Exception as e:
        print(f"Error listing objects in bucket {bucket_name}: {e}")
        return []

def create_zip_file(bucket_name, zip_filename):
    """
    Creates a zip file containing all objects from the specified S3 bucket.
    The zip file is stored in the same bucket.
    """
    s3 = boto3.client('s3')
    try:
        objects = list_s3_objects(bucket_name)
        with zipfile.ZipFile(zip_filename, 'w') as zipf:
            for obj_key in objects:
                obj = s3.get_object(Bucket=bucket_name, Key=obj_key)
                data = obj['Body'].read()
                zipf.writestr(obj_key, data)
        s3.upload_file(zip_filename, bucket_name, zip_filename)
        print(f"Zip file '{zip_filename}' created and uploaded to S3 bucket '{bucket_name}'.")
    except Exception as e:
        print(f"Error creating and uploading zip file: {e}")

if __name__ == "__main__":
    # Replace with your S3 bucket name
    bucket_name = "testbucket-fred763gd7"
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    zip_filename = f"{timestamp}.zip"
    create_zip_file(bucket_name, zip_filename)
