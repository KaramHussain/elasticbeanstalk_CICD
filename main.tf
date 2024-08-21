provider "aws" {
  region = "us-east-1"
}


##################################################
##################   VPC   #######################
##################################################

# Creating VPC
module "vpc" {
  source                     = "./modules/vpc"
  vpc_cidr_block             = var.vpc_cidr
  vpc_name                   = var.vpc_name
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones         = var.availability_zones
}

####################################################
################ Elastic BeanStalk #################
####################################################

# Creating Security Group for Elastic Beanstalk
module "security_group" {
  source        = "./modules/security_group"
  description   = var.elb_security_group_description
  name          = var.elb_security_group_name
  ingress_rules = var.elb_taskapp_ingress_rules
  vpc_id        = module.vpc.vpc_id
}

#### Creating Instance Profile for Elastic Beanstalk
module "netframwork1_instance_profile" {
  source = "./modules/ec2_instance_profile"
  instance_profle_RoleName = var.instance_profle_RoleName
  aws_iam_instance_profile_name = var.instance_profile_name
}

#### Creating Elastic Beanstalk
module "netframework1_elasticBeansStalk" {
  source = "./modules/elasticBeanstalk"
  application_name = var.application_name
  environment_name = var.environment_name
  solution_stack_name = var.solution_stack_name
  instance_type = var.instance_type
  health_check_path = var.health_check_path
  min_instance_count = var.min_instance_count
  max_instance_count = var.max_instance_count
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_group.security_group_id
  elb_scheme = var.elb_scheme
  instance_profile_role_arn = module.netframwork1_instance_profile.instance_profile_name
}


#####################################################################
####################  Creating Pipeline #############################
#####################################################################


###### Creating IAM Role for CodeBuild 
module "codeBuild_iam" {
  source    = "./modules/IAM_Role_CodeBuild"
  role_name = var.codeBuild_iam_role_name
}

###### Creating IAM Role for CodePipeline
module "PipelineIAMRole" {
  source = "./modules/iam_codepipeline"
  name   = "IamRoleForCodePipeline"
}


###### Creating S3 Bucket for Pipeline
module "Pipeline_S3" {
  source      = "./modules/s3_pipeline"
  bucket_name = var.Pipeline_S3BucketName
}


#### Creating CodeBuild 
module "CodeBuild" {
  source   = "./modules/code_build"
  name     = var.CodeBuildName
  role_arn = module.codeBuild_iam.codebuild_role_arn
}



### Creating Pipeline
module "CodePipeline" {
  source       = "./modules/code_pipeline"
  name         = var.CodePipelineName
  pipeline_arn = module.PipelineIAMRole.codepipeline_role_arn
  s3_bucket    = module.Pipeline_S3.s3_bucket
  build_name   = module.CodeBuild.codebuildname
  FullRepositoryId = var.FullRepositoryId
  BranchName = var.BranchName
  ConnectionArn = var.ConnectionArn
  BuildProjectName = module.CodeBuild.codebuildname
  Provider = var.Provider
  EnvironmentName = var.environment_name
}