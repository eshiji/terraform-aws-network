# Common
variable "project_name" {
  type        = string
  description = "Nimbus project name"
  default     = "ml-platform"
}

/* variable "env" {
  type        = string
  description = "Environment: staging, prod..."
  default     = "staging"
} */

variable "region" {
  type        = string
  description = "AWS region to create the resources"
  default     = "us-east-1"

  validation {
    condition     = contains(["us-west-2", "us-east-1", "us-east-2"], var.region)
    error_message = "Region value is not in the allowed list of regions."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "A list with availability zones to create the resources (subnets, )."
  default     = ["us-east-1a", "us-east-1b"]
}


# VPC
variable "vpc" {
  description = "The VPC arguments values"
  type = object({
    cidr_block                       = string
    instance_tenancy                 = string
    enable_dns_support               = bool
    enable_dns_hostnames             = bool
    enable_classiclink               = bool
    enable_classiclink_dns_support   = bool
    assign_generated_ipv6_cidr_block = bool
  })
  default = {
    cidr_block                       = "10.0.0.0/16"
    instance_tenancy                 = "default"
    enable_dns_support               = true
    enable_dns_hostnames             = false
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    assign_generated_ipv6_cidr_block = false
  }
}

# Subnets
variable "subnets" {
  description = "AWS Subnets arguments values."
  type = object({
    assign_ipv6_address_on_creation = bool
    availability_zone               = list(string)
    cidr_blocks                     = list(string)
    # Starts with 0 (e.g. count = 4 -> [0,1,2,3])
    count                                          = number
    enable_dns64                                   = bool
    enable_resource_name_dns_aaaa_record_on_launch = bool
    enable_resource_name_dns_a_record_on_launch    = bool
    ipv6_native                                    = bool
    map_customer_owned_ip_on_launch                = bool
    map_public_ip_on_launch                        = bool
    netnum                                         = number
    newbits                                        = number
  })
  default = {
    assign_ipv6_address_on_creation                = false
    availability_zone                              = ["us-east-1a", "us-east-1b"]
    cidr_blocks                                    = []
    count                                          = 4
    enable_dns64                                   = false
    enable_resource_name_dns_aaaa_record_on_launch = false
    enable_resource_name_dns_a_record_on_launch    = false
    ipv6_native                                    = false
    map_customer_owned_ip_on_launch                = false
    map_public_ip_on_launch                        = false
    netnum                                         = 1
    newbits                                        = 8
  }
}

# ECR Endpoint
variable "create_ecr_endpoint" {
  description = "Whether ECR and ECR API endpoint should be created (default = false)"
  type        = bool
  default     = true
}

variable "create_s3_gateway_endpoint" {
  description = "Whether s3 Gateway endpoint will be created (default = false)"
  type        = bool
  default     = true
}

# Tags
variable "additional_tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}
