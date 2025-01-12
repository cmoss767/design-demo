## Overview
This project implements a highly scalable, low-latency API service that can be deployed both in AWS cloud and on-premise environments. The service is containerized using Docker and supports horizontal scaling with load balancing.

## Architecture Diagrams
https://drive.google.com/file/d/1w6QiRmISYwOfvBvqdnYF_k_70J3f5bBx/view?usp=sharing


## On-Premise Setup Instructions

### Prerequisites
- Docker installed
- Docker Compose installed
- Git

### Setup Steps

1. Clone repository

2. Build and start the services:
```bash
docker-compose up --scale api-dev=2
```

3. Test the endpoint:
```bash
curl http://localhost:80/
```

## AWS Deployment

### Prerequisites
- AWS CLI installed and configured with appropriate credentials
- Docker installed and running
- Git

### IAM Policies needed
[
    "AmazonECS_FullAccess",
    "AmazonEC2ContainerRegistryFullAccess",
    "AmazonEC2FullAccess",
    "IAMFullAccess",
    "AWSCloudFormationFullAccess"
]

### Deployment Steps

1. Create ECR repo and push docker image:
```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECR_URL=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

docker build -f docker/Dockerfile.prod -t hello-world-api .
docker tag hello-world-api:latest $ECR_URL/hello-world-api:latest
docker push $ECR_URL/hello-world-api:latest
```

2. Deploy CloudFormation stack:
```bash
cd infrastructure
bash ./deploy.sh
run deploy script
```

3. Test the deployment:
```bash
aws cloudformation describe-stacks \
    --stack-name ecs \
    --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
    --output text

curl http://ecs-LoadBalancer-XXXXXXXXXXXXX.us-east-1.elb.amazonaws.com
```

### Cleanup
```bash
cd infrastructure
bash ./cleanup.sh
```
