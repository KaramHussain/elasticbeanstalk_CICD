variable "name" {
  description = "Prefix for resource names"
  type        = string
}

variable "pipeline_arn" {
  type        = string
}

variable "s3_bucket" {
  type        = string
}

variable "build_name" {
  type        = string
}

variable "repo_owner" {
  type        = string
}
variable "repo_name" {
  type        = string
}
variable "repo_branch" {
  type        = string
}