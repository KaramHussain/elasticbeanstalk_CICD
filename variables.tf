variable "region" {
  default = "us-west-2"
}
#####################   VPC
# Declare variable for private subnet CIDR blocks
variable "private_subnet_cidr_blocks" {
  description = "value of the private subnet CIDR block"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Declare variable for public subnet CIDR blocks
variable "public_subnet_cidr_blocks" {
  description = "value of the public subnet CIDR block"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

}

variable "availability_zones" {
  type        = list(string)
  description = "value of the availability zones"
  default     = ["us-east-1a", "us-east-1b"]
}





variable "application_name" {
  default = "sample-dotnet-app"
}

variable "environment_name" {
  default = "sample-dotnet-env"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "health_check_path" {
  default = "/"
}


#############################################################

variable "elb_security_group_name" {
  type        = string
  default     = "beanstalk_demo_elb_sg"
  description = "value of the security group name"

}

#############################################################

variable "elb_security_group_description" {
  type        = string
  default     = "Allow HTTP and HTTPS traffic"
  description = "value of the security group name"

}


#####################  Security Group #################################

variable "elb_taskapp_ingress_rules" {
  description = "List of ingress rule objects"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "NFS ingress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}


##################### Code Build Role Name ##########################

variable "codebuild_name" {
  default = "dotnet_app_demo"
}

##################### Code Pipeline Role Name #######################

variable "CodePipelineRoleName" {
  default = "dotnet_app_demo_pipeline"
}


####################### CodeBuild Name ###############################

variable "CodeBuildName" {
  default = "dotnet_app_demo_build"
}

####################### CodePipeline Name ############################

variable "CodePipelineName" {
  default = "dotnet_app_demo_pipeline"
}
