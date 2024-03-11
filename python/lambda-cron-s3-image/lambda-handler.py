import boto3
import requests
import datetime
import os
import io

s3 = boto3.client('s3')
cloudwatch = boto3.client('cloudwatch')

image_url = 'https://online.aberdeencity.gov.uk/services/Webcam/images/beach.jpg'

def main(event, context):
    # Download the image
    response = requests.get(image_url)
    image_data = response.content

    # Get the current timestamp
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')

    # Create a new filename with the timestamp
    filename = f'image_{timestamp}.jpg'

    # Upload the image to S3 with the new filename
    bucket_name = os.getenv('BUCKET_NAME')
    s3.upload_fileobj(io.BytesIO(image_data), bucket_name, filename)

    # Log the successful event to CloudWatch
    cloudwatch.put_metric_data(
        Namespace='AWS/Lambda',
        MetricData=[
            {
                'MetricName': 'SuccessfulImageUpload',
                'Value': 1,
                'Unit': 'Count'
            }
        ]
    )
