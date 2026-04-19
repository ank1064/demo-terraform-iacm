terraform {
  required_version = ">= 1.0.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "dev"
}

variable "instance_count" {
  description = "Number of simulated instances"
  type        = number
  default     = 2
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "demo-app"
}

resource "random_id" "deployment" {
  byte_length = 4
}

resource "null_resource" "simulate_infra" {
  count = var.instance_count

  triggers = {
    environment   = var.environment
    instance_id   = count.index
    deployment_id = random_id.deployment.hex
  }

  provisioner "local-exec" {
    command = "echo Provisioned instance ${count.index} in ${var.environment} environment"
  }
}

resource "local_file" "deployment_manifest" {
  content = jsonencode({
    app_name      = var.app_name
    environment   = var.environment
    deployment_id = random_id.deployment.hex
    instances     = var.instance_count
  })
  filename = "${path.module}/deployment-manifest.json"
}

output "deployment_id" {
  description = "Unique deployment identifier"
  value       = random_id.deployment.hex
}

output "environment" {
  description = "Target environment"
  value       = var.environment
}

output "instance_count" {
  description = "Number of provisioned instances"
  value       = var.instance_count
}

output "manifest_path" {
  description = "Path to deployment manifest"
  value       = local_file.deployment_manifest.filename
}
