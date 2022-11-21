#!/bin/bash
set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get default.region)

echo "ACCOUNT_ID: $ACCOUNT_ID"
echo "REGION: $REGION"
sleep 1

docker build -t python-ping-api . --platform linux/amd64

docker tag python-ping-api:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/python-ping-api:latest

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/python-ping-api:latest