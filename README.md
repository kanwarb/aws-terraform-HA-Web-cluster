# aws-terraform-HA-Web-cluster


### DRY Automation with Terraform, Secured with Vault provisiond on AWS 

-  This repository allows you to deploy a high availability cluster of Webserver in the us-east-1 region
-  You can change regions in the main.tf module service

- The layout is designed to  deployment a HA cluster of Webservers with autoscaling using following AWS resources

	-  Elastic Load Balancer
	-  Auto Scaling Group
	-  Launch Configuration
	-  S3 for state files
	-  Security Group for EC2 instances 
	-  Security Group for Elastic Load Balancer

-  The provisioning requires that you have Vault configured and setup 
![Vault provisining]("https://www.vaultproject.io/docs/secrets/aws/index.html")

-  PS: This cluster built is using free tier to avoid costs. Please check before deploying if you do not want to incur cost on AWS. 
-  You can use the same code layout to deploy this on your own infrastructure or another cloud provider
