# Python sample project for EKS

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_eks-python-api&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_eks-python-api) [![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_eks-python-api&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_eks-python-api)

The sample project to deploy Python REST API application, Service, HorizontalPodAutoscaler, Ingress on EKS.

- [app.py](app/app.py)
- [Dockerfile](app/Dockerfile)
- [python-ping-api-template.yaml](app/python-ping-api-template.yaml)

---

## Prerequisites

### Installation

- [Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Set AWS configurations

Set AWS configurations with `aws configure` for default region and keys:

```bash
aws configure
```

```bash
AWS Access Key ID [None]: <enter-your-access-key>
AWS Secret Access Key [None]: <enter-your-secret-key>
Default region name [None]: us-east-1
Default output format [None]: 
```

```bash
aws configure get default.region
us-east-1
```

---

## Create an EKS cluster and deploy AWS Load Balancer Controller

Refer to the https://github.com/DevSecOpsSamples/eks-eksctl page.

## Set environment variables

```bash
REGION=$(aws configure get default.region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CLUSTER_NAME=$(kubectl config current-context | cut -d '@' -f2 | cut -d '.' -f1)
echo "REGION: ${REGION}, ACCOUNT_ID: ${ACCOUNT_ID}, CLUSTER_NAME: ${CLUSTER_NAME}"
```

## Deploy python-ping-api

Build and push to ECR:

```bash
cd ../app
docker build -t python-ping-api . --platform linux/amd64

docker tag python-ping-api:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/python-ping-api:latest

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/python-ping-api:latest
```

Create and deploy K8s Deployment, Service, HorizontalPodAutoscaler, Ingress using the [python-ping-api-template.yaml](app/python-ping-api-template.yaml) template file.

```bash

sed -e "s|<account-id>|${ACCOUNT_ID}|g" python-ping-api-template.yaml | sed -e "s|<region>|${REGION}|g" > python-ping-api.yaml
cat python-ping-api.yaml

kubectl apply -f python-ping-api.yaml
```

It may take around 5 minutes to create a load balancer, including health checking.

Confirm that Pod and ALB logs.

```bash
kubectl logs -l app=python-ping-api

kubectl describe pods

kubectl logs -f $(kubectl get po -n kube-system | egrep -o 'aws-load-balancer-controller-[A-Za-z0-9-]+') -n kube-system
```

---

## Cleanup

```bash
kubectl delete -f app/python-ping-api.yaml

```

## References

- [Application load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
