# Python-S3-Downloader

This script creates a zip file of every object in a specified s3 bucket in these stages:
- List all objects
- Zip all objects and put the zip into the bucket

# Usage

- Ensure AWS CLI is installed and configured. If not yet then:
```bash
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
$ aws configure # paste access key, secret key, region
```
- Clone this repo
- Create and activate a virtual environment (install venv beforehand if required)
```bash
$ sudo apt install python3.10-venv
$ python3 -m venv .env
$ source .env/bin/activate
```
- Install required modules
```bash
$ pip install -r requirements.txt
```
- Configure the variable __bucket_name__ in main.py (i.e. specify your target bucket)
- Run this script
```bash
$ python3 main.py
```
