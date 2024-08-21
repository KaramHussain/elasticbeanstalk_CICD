variable "region" {
  default = "us-west-2"
}

##################################################
##################   VPC   #######################
##################################################

# VPC_CIDR
variable "vpc_cidr" {
  description = "value of the VPC CIDR block"
  type        = string
  default     = "10.0.0.0/24" 
}

# Declare variable for VPC name
variable "vpc_name" {
  description = "value of the VPC name"
  type        = string
  default     = "sample-vpc"
}


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

# choosing AZ where we want our EC2 to be created
variable "availability_zones" {
  type        = list(string)
  description = "value of the availability zones"
  default     = ["us-east-1a", "us-east-1b"]
}

##################################################
##########  Elastic Bean Stalk    ################
##################################################


variable "instance_profile_name" {
  description = "value of the instance profile name"
  default = "elasticbeanstalk_ec2_ProfileName"
  type = string
}

variable "instance_profle_RoleName"  {
    description = "The name of the instance profile"
    type        = string
    default = "NetFramework_elasticbeanstalk_ec2_Role"
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

variable "min_instance_count" {
  default = 1
}

variable "max_instance_count" {
  default = 4
}

variable "solution_stack_name" {
  default = "64bit Amazon Linux 2023 v3.1.5 running .NET 6"
}

variable "elb_scheme" {
  default = "public"
}


#####################  Security Group #################################
variable "elb_security_group_name" {
  type        = string
  default     = "beanstalk_demo_elb_sg"
  description = "value of the security group name"

}

#####################  Security Group Description #####################
variable "elb_security_group_description" {
  type        = string
  default     = "Allow HTTP and HTTPS traffic"
  description = "value of the security group name"

}

#####################  Ingress Rules ##################################
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



##################################################
#################  Pipeline    ###################
##################################################

################ Code Build Role Name ############

variable "codeBuild_iam_role_name" {
  default = "dotnet_app_demo_build_role"
}


##################### Code Pipeline Role Name #######################
variable "CodePipelineRoleName" {
  default = "dotnet_app_demo_pipeline"
}

######################## S3 Pipeline Bucket Name #####################
variable "Pipeline_S3BucketName" {
  default = "pipelineelastic12312-artifiacts"
}

####################### CodePipeline Name ############################
variable "CodePipelineName" {
  default = "dotnet_app_demo_pipeline"
}

####################### CodeBuild Name ###############################
variable "CodeBuildName" {
  default = "dotnet_app_demo_build"
}

variable "FullRepositoryId" {
  default = "KaramHussain/WebApplication1"
}
variable "BranchName" {
  default = "main"
}
variable "ConnectionArn" {
  default = "arn:aws:codeconnections:us-east-1:905418229977:connection/b54583e7-e022-46e1-be83-58824271e45f"
  
}

variable "BuildProjectName" {
  default = "dotnet_app_demo_build"
} 

variable "Provider" {
  default = "ElasticBeanstalk"
}

