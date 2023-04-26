# N4K Github GCP Bastion Instance

Unfortunately, there is no similar bastion function in the Google Cloud as in Azure. That means RDP or SSH via the web browser. That's why I solved this problem for the GCP with a Guacamole server. The aim is to access internal resources (SSH or RDP) only via the web. For this I create a Guacamole server with an SSL certificate from LetsEncrypt, and a Windows test VM to test the access. I create the whole thing in Github with a workflow, so you have to create some API keys. My runs are stored in the Terraform Cloud, so that you can store all passwords or sensitive data with variables there.

## Steps

To do in Google Cloud first:

- Create a project
- Create a service account in IAM - Role:Owner
- Create a key for this service account (Keys)
- This key - is a json file - then demined, so all blanks out,can be done here:
  https://tools.knowledgewalls.com/json-to-string
  this is then the GCP Credentials key in TF Cloud

To do in Terraform Cloud:

- Create a new workspace - Default Project - API Driven
- In this define the following variables:
  - GCP_Bastion_Admin_PW - is the password for the local admin user
  - GCP_Bastion_PW - Sensitive Value - is the password for the Guacamole mySQL part
  - gcp_credentials - Sensitive Value - Google Cloud service account credentials
  - GCP_PROJECT - is the name of your project - which must already be created - unfortunately
  - GITHUB_OWNER - your Github token name you created under settings-developer settings - personal access tokens - tokens
  - GITHUB_SECRET - here the secret of your Github token
- Create a user token under User Settings - Tokens
  (You must click on your Profile Icon on the bottom left)
- Copy token on a save place for later

To do in Github:

- In your repo go to - Settings - new Secret - TF_API_TOKEN - copy the secret from the TF Cloud - User Token. If not already created, then as described above - under settings-developer settings - personal access tokens - tokens - create a new Github API token - for the terraform cloud login - GITHUB_OWNER and GITHUB_SECRET

```
My variables:

# Define variables
variable "GITHUB_SECRET" {}
variable "GITHUB_OWNER" {}

variable "gcp_credentials" {
  type = string
  sensitive = true
  description = "Google Cloud service account credentials"
}

variable "GCP_Bastion_PW" {
  type = string
  sensitive = true
  description = "Guacamole MySQL Password"
}

variable "GCP_Bastion_Admin_PW" {
  type = string
  description = "Local Windows Admin Password"
}
```

## providers.tf

This is a Terraform configuration file in the HCL (HashiCorp Configuration Language) syntax. Here is what the code does:

- terraform block: This specifies the version of Terraform being used, and any required provider plugins. In this case, it sets up the Terraform Cloud backend to store the state and workspace, and specifies the required version of the github provider.
- provider "google" block: This sets up the Google Cloud provider, specifying the project name, region and service account credentials. The impersonate_service_account option is commented out, but it can be used to specify a service account to impersonate for access control purposes.
- provider "github" block: This sets up the Github provider, specifying the Github API token and the owner of the repository.

Overall, this configuration file sets up Terraform to use the Terraform Cloud backend and two provider plugins for Google Cloud and Github. The providers will be used to create and manage resources in these services.

## main.tf

This code is used to create resources in the Google Cloud Platform (GCP) using Terraform. 

- The code first creates a Compute Engine API for the project. Then it creates a virtual private cloud (VPC) and a custom subnet within that VPC. The VPC is named according to the value of the `var.vpc1` variable, while the subnet is named as `${var.vpc1}-subnet-01`. The IP address range for the subnet is set to the value of the `var.cidr-gcp` variable. 

- Next, the code creates a Cloud NAT (network address translation) to allow all VM instances to have internet access. It first creates a router named `${var.vpc1}-router-01` and assigns it to the previously created VPC. The router is also assigned an autonomous system number (ASN) of 64514. Then it creates a NAT named `${var.vpc1}-router-nat-01`, which is associated with the router and allows all subnetwork IP ranges to be NAT-ed to the internet using the `ALL_SUBNETWORKS_ALL_IP_RANGES` option. 

- These resources are all created using the `google_compute_network`, `google_compute_subnetwork`, `google_compute_router`, and `google_compute_router_nat` resources, with various attributes defined for each resource. The specific values of the attributes are taken from the `var` variables defined elsewhere in the Terraform code.