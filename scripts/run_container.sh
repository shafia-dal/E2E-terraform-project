#!/bin/bash
AWS_ACCOUNT_ID= 091846656105
AWS_REGION=us-east-1
IMAGE_REPO_NAME="my-nodejs-repo" # Ensure this matches your buildspec
IMAGE_TAG=latest # Get the specific commit/build ID


docker run -d --name my-nodejs-app \
    -p 4000:4000 \
    -e NODE_ENV=production \
    "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG"