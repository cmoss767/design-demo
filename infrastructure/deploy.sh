#!/bin/bash
set -e

echo "Starting deployment..."

echo "Deploying network stack..."
aws cloudformation deploy \
  --stack-name network \
  --template-file network.yaml \
  --no-fail-on-empty-changeset

VPC_ID=$(aws cloudformation describe-stacks --stack-name network --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' --output text)
SUBNET_IDS=$(aws cloudformation describe-stacks --stack-name network --query 'Stacks[0].Outputs[?OutputKey==`SubnetIds`].OutputValue' --output text)

echo "Deploying security stack..."
aws cloudformation deploy \
  --stack-name security \
  --template-file security.yaml \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    VpcId=$VPC_ID \
  --no-fail-on-empty-changeset

SECURITY_GROUP_ID=$(aws cloudformation describe-stacks --stack-name security --query 'Stacks[0].Outputs[?OutputKey==`SecurityGroupId`].OutputValue' --output text)
INSTANCE_PROFILE_ARN=$(aws cloudformation describe-stacks --stack-name security --query 'Stacks[0].Outputs[?OutputKey==`InstanceProfileArn`].OutputValue' --output text)

echo "Deploying ECS stack..."
aws cloudformation deploy \
  --stack-name ecs \
  --template-file ecs.yaml \
  --parameter-overrides \
    VpcId=$VPC_ID \
    SubnetIds=$SUBNET_IDS \
    SecurityGroupId=$SECURITY_GROUP_ID \
    InstanceProfileArn=$INSTANCE_PROFILE_ARN \
  --no-fail-on-empty-changeset

echo "Deployment complete!" 