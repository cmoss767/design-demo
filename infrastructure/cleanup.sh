#!/bin/bash
set -e

echo "Starting cleanup..."

echo "Deleting ECS stack..."
aws cloudformation delete-stack --stack-name ecs
aws cloudformation wait stack-delete-complete --stack-name ecs

echo "Deleting security stack..."
aws cloudformation delete-stack --stack-name security
aws cloudformation wait stack-delete-complete --stack-name security

echo "Deleting network stack..."
aws cloudformation delete-stack --stack-name network
aws cloudformation wait stack-delete-complete --stack-name network

echo "Deleting ECR repository..."
aws ecr delete-repository --repository-name hello-world-api --force

echo "Cleanup complete!"