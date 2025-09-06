variable "aws_region"        { type = string }
variable "instance_type"     { type = string  default = "t3.micro" }
variable "key_name"          { type = string }
variable "allowed_ssh_cidr"  { type = string  default = "0.0.0.0/0" } # ideally set to Jenkins IP/32

