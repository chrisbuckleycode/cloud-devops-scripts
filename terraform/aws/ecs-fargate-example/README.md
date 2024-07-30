# ECS Fargate Example

- Simple example
- Hello world demo, node app exposed on port 3000
- First app uses public image (no own build to private registry - future improvement for second app)
- Includes VPC (2 private subnets, 2 public subnets)

# Instructions

## Terraform Install
```bash
wget https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip ./terraform_1.7.5_linux_amd64.zip
mv ./terraform /usr/local/bin
```


## Set Env Variables

```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_REGION=us-east-1
```

## Terraform Apply

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Terraform Change No. ECS Tasks

```bash
terraform plan -var app_count=4 -out=tfplan
terraform apply tfplan
```

## Terraform Destroy

```bash
terraform plan -destroy -out=tfplan
terraform apply tfplan
```
