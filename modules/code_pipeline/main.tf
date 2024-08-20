##################### CodeDeploy Application #########

resource "aws_codedeploy_app" "deploy_app" {
  compute_platform = "Server"
  name             = "sample-dotnet-app"
}


##################### CodePipeline #####################
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
        # FullRepositoryId = "KaramHussain/WebApplication1"
        FullRepositoryId = var.FullRepositoryId
        # BranchName = "main"     
        BranchName = var.BranchName    
        # ConnectionArn   = "arn:aws:codeconnections:us-east-1:905418229977:connection/b54583e7-e022-46e1-be83-58824271e45f"
        ConnectionArn   = var.ConnectionArn
      
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
        ProjectName = var.BuildProjectName
      }
    }
  }

  stage {
    name = "Deploy"

    action {
    name        = "DeployAction"
    category    = "Deploy"
    owner       = "AWS"
    provider    = var.Provider
    version     = "1"
    input_artifacts = ["build_output"] 


      configuration = {
        ApplicationName    = aws_codedeploy_app.deploy_app.name 
        EnvironmentName = var.EnvironmentName
      
      }
    }
  }
}


