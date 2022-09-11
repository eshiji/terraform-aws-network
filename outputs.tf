# VPC
output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.vpc.id
}

output "vpc_arn" {
  description = "Amazon Resource Name (ARN) of VPC."
  value       = aws_vpc.vpc.arn
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support."
  value       = aws_vpc.vpc.enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support."
  value       = aws_vpc.vpc.enable_dns_hostnames
}

output "vpc_enable_classiclink" {
  description = "Whether or not the VPC has Classiclink enabled."
  value       = aws_vpc.vpc.enable_classiclink
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC."
  value       = aws_vpc.vpc.owner_id
}

# Public Subnet
output "public_subnet_id" {
  description = "The ID of the subnet."
  value       = aws_subnet.public[*].id
}

output "public_subnet_arn" {
  description = "The ARN of the subnet."
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidr_block" {
  description = "The IPv4 CIDR block for the subnet."
  value       = aws_subnet.public[*].cidr_block
}

# Private Subnet
output "private_subnet_id" {
  description = "The ID of the subnet."
  value       = aws_subnet.private[*].id
}

output "private_subnet_arn" {
  description = "The ARN of the subnet."
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidr_block" {
  description = "The IPv4 CIDR block for the subnet."
  value       = aws_subnet.private[*].cidr_block
}

# Internet Gateway
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.igw.id
}

output "internet_gateway_arn" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.igw.arn
}

output "internet_gateway_owner_id" {
  description = "The ID of the AWS account that owns the internet gateway."
  value       = aws_internet_gateway.igw.owner_id
}


# Nat Gateway
output "nat_gateway_allocation_id" {
  description = "ID that AWS assigns to represent the allocation of the Elastic IP address for use with instances in a VPC."
  value       = aws_nat_gateway.nat_gtw[*].allocation_id
}

output "nat_gateway_id" {
  description = "Contains the EIP allocation ID."
  value       = aws_nat_gateway.nat_gtw[*].id
}

output "nat_gateway_public_ip" {
  description = "Contains the public IP address."
  value       = aws_nat_gateway.nat_gtw[*].public_ip
}

output "nat_gateway_subnet_id" {
  description = "The Subnet ID of the subnet in which to place the gateway."
  value       = aws_nat_gateway.nat_gtw[*].subnet_id
}

output "nat_gateway_connectivity_type" {
  description = "Connectivity type for the gateway. Valid values are private and public. Defaults to public."
  value       = aws_nat_gateway.nat_gtw[*].connectivity_type
}

# Elastic IP
output "eip_id" {
  description = "Contains the EIP allocation ID."
  value       = aws_eip.eip_nat[*].id
}

output "eip_public_ip" {
  description = "Contains the public IP address."
  value       = aws_eip.eip_nat[*].public_ip
}

# Public route table
output "public_route_table_id" {
  description = "The ID of the routing table."
  value       = aws_route_table.public.id
}

output "public_route_table_arn" {
  description = "The ARN of the route table."
  value       = aws_route_table.public.arn
}

output "public_route_table_igw_id" {
  description = "The Internet Gateway ID in route table route."
  value       = aws_route_table.public.route[*]["gateway_id"]
}

# Private route table
output "private_route_tables_id" {
  description = "The ID of the routing table."
  value       = aws_route_table.private[*].id
}

output "private_route_table_arn" {
  description = "The ARN of the route table."
  value       = aws_route_table.private[*].arn
}

output "private_route_table_nat_gtw_id" {
  description = "The NAT Gateway id in route table route"
  value       = aws_route_table.private[*].route[*]["nat_gateway_id"]
}
