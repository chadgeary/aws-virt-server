output "cloudworkstation-output" {
  value = <<OUTPUT
## SSH ##
ssh ubuntu@${aws_eip.cw-eip-1.public_ip}
  
## WebUI ##
# Username: guacadmin
https://${var.enable_duckdns == 1 ? var.duckdns_domain : aws_eip.cw-eip-1.public_ip}/guacamole/
  
## Container Updates ##
# SSH (or RDP) to instance
ssh ubuntu@${aws_eip.cw-eip-1.public_ip}

# Remove old containers
sudo docker rm -f web_proxy guacamole guacdb guacd duckdnsupdater

# Re-run the playbook via AWS SSM from your local machine
aws --region ${var.aws_region} --profile ${var.aws_profile} ssm start-associations-once --association-ids ${aws_ssm_association.cw-ssm-assoc.association_id}

# To stop or start the instance
aws --region ${var.aws_region} --profile ${var.aws_profile} ec2 stop-instances --instance-ids ${aws_instance.cw-instance-1.id}
aws --region ${var.aws_region} --profile ${var.aws_profile} ec2 start-instances --instance-ids ${aws_instance.cw-instance-1.id}
OUTPUT
}
