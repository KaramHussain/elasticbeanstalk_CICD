resource "aws_iam_role" "codebuild_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_power_user" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.role_name}-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:*"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "*",
        ],
        Action = [
          "logs:*"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "*"
        ],
        Action = [
          "s3:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:*"
        ],
        Resource = [
              "*"
        ]
      }
    ]
  })
}