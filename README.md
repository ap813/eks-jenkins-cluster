# eks-jenkins-cluster

## What is going on here

This project creates an EKS cluster in the desired region you want. The terraform IaC will also deploy the AWS Load Balancer add-on into the cluster, so that EKS can manage the creation of load balancers for services. It will utilize the add-on to deploy a custom Jenkins image fronted by an internet-facing ALB. The Jenkins service will only allow authorized users to login. It will provision the admin user with specified username and password stored in a Kubernetes secrets.

## What you'll need

1. A unix based operating system
2. [Terragrunt](https://terragrunt.gruntwork.io/) and Terraform installed
3. An AWS Account
4. An AWS user credential that can provision all of the resources (EKS, IAM, S3, EC2, etc.)
5. Kubectl installed on your machine
6. envsubst
7. [Gum](https://github.com/charmbracelet/gum) for glorious shell scripts!

## Project Overview

Once you have everything installed you can start creating. The project is split into 3 parts.

1. Terraform AWS infrastructure + Helm chart for the AWS Load Balancer add-on
2. Custom Jenkins image that is deployed to ECR
3. Kubernetes resources that are stored in deployment.yml

## Terraform infrastructure

During the creation of this part of the project, I saw some issues around authenticating to my EKS cluster with the kubernetes and helm Terraform providers. The main issue revolved around v1beta1 now working with my cluster and v1alpha1 not being supported. I decide to fix this problem by using tokens from my cluster:

```hcl
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
```

## Jenkins customizations

I wrote some Jenkins customizations so that I didn't have to go through configuring the deployment after it spun up, this process is coined Jenkins Configuration as Code (JCasC). The customizations that I added were to install specific plug-ins and create an admin user while blocking all access to unauthorized users.

From there you can managed the Jenkins instance however you like.

## AWS Load Balancer intergration

The AWS load balancer integration for EKS is a nice addition to this project. It allows the cluster to provision Elastic Load Balancers in your AWS account and the supported resources for its configuration. in the deployment.yml file, the Ingress resource will make an internet-facing ALB that serves traffic to our Jenkins instance. This emphasizes the importance of having the Jenkins deployment with a password protected user.

## Putting it all together

To provision all of the resources I recommend creating an AWS profile for your specific account. Once ready, use the [setup.sh](./setup.sh) to create all of the infrastructure. You can use the [teardown.sh](./teardown.sh) script once you're done to take everything down as well.