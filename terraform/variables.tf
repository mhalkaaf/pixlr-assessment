# Input Variables
variable "aws_region" {
  description = "Regions of AWS Resource"
  type        = string
}

variable "ec2_instance_type" {
  description = "Type of EC2 Instance"
  type        = string
}

variable "ec2_ami_id" {
  description = "EC2 Instance AMI ID"
  type        = string
}

variable "ssh_ingress_cidr_blocks" {
  description = "Allowd IP to access EC2 Server"
  type        = list(string)
}