provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

resource "aws_elastic_beanstalk_application" "application" {
  name = var.application_name
}

module "vpc" {
  source                     = "./modules/vpc"
  vpc_cidr_block             = "10.0.0.0/16"
  vpc_name                   = "sample-vpc"
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones         = var.availability_zones
}

module "security_group" {
  source        = "./modules/security_group"
  description   = var.elb_security_group_description
  name          = var.elb_security_group_name
  ingress_rules = var.elb_taskapp_ingress_rules
  vpc_id        = module.vpc.vpc_id
}

resource "aws_iam_role" "ec2_role" {
  name = "aws-elasticbeanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })

}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "aws-elasticbeanstalk-ec2-role"
  role = aws_iam_role.ec2_role.name
}

resource "aws_elastic_beanstalk_environment" "environment" {
  wait_for_ready_timeout = "30m"
  name                   = var.environment_name
  application            = aws_elastic_beanstalk_application.application.name
  solution_stack_name    = "64bit Amazon Linux 2023 v3.1.5 running .NET 6"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = var.health_check_path
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.vpc.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", module.vpc.private_subnet_ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", module.vpc.public_subnet_ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = module.security_group.security_group_id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.instance_profile.arn
  }
}

data "aws_availability_zones" "available" {}


module "Pipeline_S3" {
  source      = "./modules/s3_pipeline"
  bucket_name = "pipelineelastic12312-artifiacts"
}

module "codeBuild_iam" {
  source    = "./modules/IAM_Role_CodeBuild"
  role_name = var.codebuild_name
}

module "PipelineIAMRole" {
  source = "./modules/iam_codepipeline"
  name   = "IamRoleForCodePipeline"
}

module "CodeBuild" {
  source   = "./modules/code_build"
  name     = var.CodeBuildName
  role_arn = module.codeBuild_iam.codebuild_role_arn
}


module "CodePipeline" {
  source       = "./modules/code_pipeline"
  name         = var.CodePipelineName
  pipeline_arn = module.PipelineIAMRole.codepipeline_role_arn
  s3_bucket    = module.Pipeline_S3.s3_bucket
  build_name   = module.CodeBuild.codebuildname
  repo_owner   = "KaramHussain"
  repo_name    = "WebApplication1"
  repo_branch  = "main"
}