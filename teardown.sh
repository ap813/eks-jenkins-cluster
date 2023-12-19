#!/usr/bin/env bash

# Set script variables
aws_profile=$(gum input --placeholder "AWS profile" --prompt="AWS profile to run the script:")
aws_account_id=$(aws sts get-caller-identity --profile $aws_profile --query "Account" --output text)
repo_name=jenkins
aws_region=us-east-2

# To return to root of script
current_directory=$(pwd)

# Remove k8s resources
cd $current_directory/k8s
kubectl delete -f deployment.yml
rm ~/.kube/config

# Remove all ECR images from Jenkins repo
aws ecr batch-delete-image --profile $aws_profile --region $aws_region \
    --repository-name $repo_name \
    --image-ids "$(aws ecr list-images --region $aws_region --repository-name $repo_name --query 'imageIds[*]' --output json
)" || true

# Destroy terraform resources
cd $current_directory/infrastructure
terragrunt run-all destroy -auto-approve -terragrunt-non-interactive