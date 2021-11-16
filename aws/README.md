# Reference
The AWS deployment for aws-virt-server.

# Requirements
- An AWS account
- Follow Step-by-Step (compatible with Windows and Ubuntu)

# Recommended
- A duckdns.org domain and token for LetsEncrypt-signed trusted HTTPS

# Deployment
```
# Change to aws dir
cd aws/

# Customize the vars file
vi cw.tfvars 

# Var notes:
 # mgmt_cidr should be the IP address you'll be connecting from (via SSH or webUI), alternatively set it to 0.0.0.0/0
 # kms_manager is your AWS IAM username, must not be root
 # visit duckdns.org to get a token and name

# Initialize terraform and apply the terraform state
terraform init
terraform apply -var-file="cw.tfvars"

# Want to watch Ansible setup the virtual machine? SSH to the cloud instance - see terraform output for SSH - after connection run:
export ASSOC_ID=$(sudo bash -c 'ls -t /var/lib/amazon/ssm/*/document/orchestration/' | awk 'NR==1 { print $1 }') && sudo bash -c 'cat /var/lib/amazon/ssm/i-*/document/orchestration/'"$ASSOC_ID"'/awsrunShellScript/runShellScript/stdout'
```

# Post-Deployment
- Wait for Ansible Playbook, watch [AWS State Manager](https://console.aws.amazon.com/systems-manager/state-manager)
- See terraform output for WebUI link. Username: `guacadmin`

# FAQs
- Using an ISP with a dynamic IP (DHCP) and the IP address changed? Pihole webUI and SSH access will be blocked until the mgmt_cidr is updated.
  - Follow the steps below to quickly update the cloud firewall using terraform.

```

# Change to the project directory
cd ~/aws-virt-server/aws/

# Update the mgmt_cidr variable - be sure to replace change_me with your public IP address
sed -i -e "s#^mgmt_cidr = .*#mgmt_cidr = \"change_me/32\"#" cw.tfvars

# Rerun terraform apply, terraform will update the cloud firewall rules
terraform apply -var-file="cw.tfvars"
```

- How do I update docker containers?
  - Containers must be removed manually first:
  - SSH to the aws-virt-server instance.
  - Remove the container(s) (local data is kept), e.g.:
```
sudo docker rm -f guacd
```
  - Re-apply the AWS SSM association to re-run the Ansible playbook. Ansible will re-install the container(s). 
  - Newer versions of aws-virt-server display an AWS CLI command to re-apply the AWS SSM association.
