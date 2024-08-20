resource "aws_codepipeline" "app_pipeline" {
  name     = var.name
  role_arn = var.pipeline_arn

  artifact_store {
    location = var.s3_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]


      configuration = {
        FullRepositoryId = "KaramHussain/WebApplication1"
         BranchName = "main"     
        ConnectionArn   = "arn:aws:codeconnections:us-east-1:905418229977:connection/b54583e7-e022-46e1-be83-58824271e45f"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = "dotnet_app_demo_build"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name        = "DeployAction"
      category    = "Deploy"
      owner       = "AWS"
      provider    = "CodeDeploy"
      version     = "1"
      input_artifacts = ["build_output"] 


      configuration = 
        ApplicationName    = aws_codedeploy_app.deploy_app.name 


        # DeploymentGroupName = aws_codedeploy_deployment_group.example.deployment_group_name  # Using the output attribute
        # DeploymentConfigName = "CodeDeployDefault.AllAtOnce"  # Or specify a custom config
      
    }
  }
}




##################### CodeDeploy Application #####################

resource "aws_codedeploy_app" "deploy_app" {
  compute_platform = "Server"
  name             = "sample-dotnet-app"
}

##################### IAM Role for CodeDeploy #####################

resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

######################### Policy for CodeDeploy #####################

resource "aws_iam_policy" "codedeploy_policy" {
  name        = "codedeploy_policy"
  description = "Policy for CodeDeploy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

######################### Attach Policy to Role #####################

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  policy_arn = aws_iam_policy.codedeploy_policy.arn
  role       = aws_iam_role.codedeploy_role.name
}

######################### Attach Managed Policy for CodeDeploy #####################

resource "aws_iam_role_policy_attachment" "aws_codedeploy_managed_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy_role.name
}




resource "aws_codedeploy_deployment_group" "example" {
  app_name              = aws_codedeploy_app.deploy_app.name
  deployment_group_name = "dotnet-app-demo-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_style {
    deployment_type = "IN_PLACE"
  }

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "sample-dotnet-env"
    }
  }
}

