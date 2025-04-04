#!/bin/bash
AWS_ACCOUNT_ID= 091846656105
AWS_REGION=us-east-1
IMAGE_REPO_NAME="my-nodejs-repo" # Ensure this matches your buildspec
IMAGE_TAG=latest # Get the specific commit/build ID


echo "Pulling Docker image from ECR:"
echo "  Registry: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
echo "  Repository: $IMAGE_REPO_NAME"
echo "  Tag: $IMAGE_TAG"
docker pull "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG"

if [ $? -eq 0 ]; then
  echo "Docker image pulled successfully."
else
  echo "Error pulling Docker image. Check logs for details."
  exit 1
fi