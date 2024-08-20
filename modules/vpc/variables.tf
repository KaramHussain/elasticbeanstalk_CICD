variable "vpc_cidr_block" {
    type    = string
    description = "value of the VPC CIDR block"
}

variable "vpc_name" {
    type    = string
  
}
# Declare variable for private subnet CIDR blocks
variable "private_subnet_cidr_blocks" {
    description = "value of the private subnet CIDR block"
    type    = list(string)
}

# Declare variable for public subnet CIDR blocks
variable "public_subnet_cidr_blocks" {
    description = "value of the public subnet CIDR block"
    type    = list(string)
}

variable "availability_zones" {
    type    = list(string)
    description = "value of the availability zones"
}