#!/usr/bin/env bash

# Set script variables
aws_profile=$(gum input --placeholder "AWS profile" --prompt="AWS profile to run the script:")
aws_account_id=$(aws sts get-caller-identity --profile $aws_profile --query "Account" --output text)
export JENKINS_ADMIN_ID=$(gum input --placeholder "username" --prompt="Jenkins admin username:")
export JENKINS_ADMIN_PASSWORD=$(gum input --placeholder "password" --prompt="Jenkins admin password:" --password)
export JENKINS_IMAGE_TAG=$(gum input --placeholder "v1" --prompt="Jenkins image tag:")

# To return to after script
current_directory=$(pwd)

touch ~/.kube/config

# Deploy AWS infra
cd $current_directory/infrastructure
terragrunt run-all apply -auto-approve -terragrunt-non-interactive

# Setup kubeconfig
cd $current_directory/infrastructure/eks
aws eks --profile $aws_profile --region $(terragrunt output -raw region) update-kubeconfig \
    --name $(terragrunt output -raw cluster_name)

# Create custom jenkins image
cd $current_directory/jenkins/build
aws ecr get-login-password --profile $aws_profile --region us-east-2 | docker login --username AWS --password-stdin $aws_account_id.dkr.ecr.us-east-2.amazonaws.com
docker buildx build --platform=linux/amd64 -t $aws_account_id.dkr.ecr.us-east-2.amazonaws.com/jenkins:$JENKINS_IMAGE_TAG .
docker push $aws_account_id.dkr.ecr.us-east-2.amazonaws.com/jenkins:v1

# Deploy Jenkins service
cd $current_directory/k8s
envsubst < deployment.yml | kubectl apply -f -

# Cleanup
unset JENKINS_ADMIN_ID JENKINS_ADMIN_PASSWORD JENKINS_IMAGE_TAG