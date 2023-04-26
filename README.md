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

(```)
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
(```) 
