## Overview
This project implements a highly scalable, low-latency API service that can be deployed both in AWS cloud and on-premise environments. The service is containerized using Docker and supports horizontal scaling with load balancing.

## Architecture Diagrams
https://drive.google.com/file/d/1w6QiRmISYwOfvBvqdnYF_k_70J3f5bBx/view?usp=sharing

## Architecture Considerations

### Scalability
#### AWS Implementation
- Application Load Balancer distributes traffic across container instances
- Configurable scaling policies based on CPU/Memory metrics
- Container-level scaling with ECS Service desired count

#### On-Premise Implementation
- Docker Compose scaling with `--scale` parameter
- Nginx load balancer for traffic distribution
- Manual scaling by adjusting container count

### Latency Optimization
#### AWS Implementation
- Multi-AZ deployment to reduce network latency

#### On-Premise Implementation
- Nginx load balancing and connection pooling

### Failover & High Availability
#### AWS Implementation
- Multi-AZ deployment ensures zone failure resilience
- Load balancer health checks (10 failed checks before removal)

#### On-Premise Implementation
- Nginx handles failed upstream servers automatically
- Multiple container instances for redundancy


## On-Premise Setup Instructions

### Prerequisites
- Docker installed
- Docker Compose installed
- Git

### Setup Steps

1. Clone repository

2. Build and start the service (below is manual scaling for 2 docker images):
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

aws ecr create-repository --repository-name hello-world-api --region us-east-1

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECR_URL=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

docker build -f Dockerfile -t hello-world-api .
docker tag hello-world-api:latest $ECR_URL/hello-world-api:latest
docker push $ECR_URL/hello-world-api:latest
```

2. Deploy CloudFormation stack:
```bash
cd infrastructure
bash ./deploy.sh
```

3. Test the deployment:
```bash
aws cloudformation describe-stacks \
    --stack-name ecs \
    --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
    --output text

# Use the LoadBalancerDNS as the URL for the curl request
curl http://ecs-LoadBalancer-XXXXXXXXXXXXX.us-east-1.elb.amazonaws.com
```

### Cleanup
```bash
cd infrastructure
bash ./cleanup.sh
```
