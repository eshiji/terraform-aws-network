locals {
  module_name = "terraform-aws-vpc"
  common_plus_additional_tags = merge(var.additional_tags, {
    resource_managed_with  = "terraform"
  })
  # If subnets.cidr_blocks list is empty, create subnet cidr blocks with subnets.count range.
  subnets_cidr_blocks = length(var.subnets.cidr_blocks) == 0 ? [for number in range(var.subnets.count) : cidrsubnet(var.vpc.cidr_block, var.subnets.newbits, number)] : var.subnets.cidr_blocks
  # Divide local.subnets_cidr_blocks in two lists
  divided_subnets_cidr_blocks = chunklist(local.subnets_cidr_blocks, length(local.subnets_cidr_blocks) / 2)
  private_subnets_cidr_blocks = local.divided_subnets_cidr_blocks[0]
  public_subnets_cidr_blocks  = local.divided_subnets_cidr_blocks[1]
}

# Virtual Private Cloud - VPC
# Amazon Virtual Private Cloud (VPC) is a service that lets you launch AWS resources in a logically isolated virtual network that you define.
# https://aws.amazon.com/vpc/features/
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc.cidr_block
  instance_tenancy = var.vpc.instance_tenancy
  # IPAM IP Address manager (organizations or one account monitoring for IP addresses)
  # ipv4_ipam_pool_id =
  # ipv4_netmask_length =
  # ipv6_cidr_block =
  # ipv6_ipam_pool_id =
  enable_dns_support               = var.vpc.enable_dns_support
  enable_dns_hostnames             = var.vpc.enable_dns_hostnames
  enable_classiclink               = var.vpc.enable_classiclink
  enable_classiclink_dns_support   = var.vpc.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.vpc.assign_generated_ipv6_cidr_block

  tags = merge(local.common_plus_additional_tags,
    { Name = "${local.module_name}" }
  )
}

# Subnets
# A subnet is a range of IP addresses in your VPC.
# https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html

# Private subnets
resource "aws_subnet" "private" {
  count                           = length(local.private_subnets_cidr_blocks)
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = local.private_subnets_cidr_blocks[count.index]
  assign_ipv6_address_on_creation = var.subnets.assign_ipv6_address_on_creation
  availability_zone               = var.subnets.availability_zone[count.index]
  # customer_owned_ipv4_pool =
  enable_dns64                                   = var.subnets.enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = var.subnets.enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = var.subnets.enable_resource_name_dns_a_record_on_launch
  # ipv6_cidr_block =
  /* ipv6_native                     = var.subnets.ipv6_native */
  /* map_customer_owned_ip_on_launch = var.subnets.map_customer_owned_ip_on_launch */
  map_public_ip_on_launch = var.subnets.map_public_ip_on_launch
  # outpost_arn =
  # private_dns_hostname_type_on_launch =

  tags = merge(local.common_plus_additional_tags,
    { Name = "${local.module_name}-private-subnet-${count.index}" }
  )
}

# Public subnets
resource "aws_subnet" "public" {
  count                           = length(local.public_subnets_cidr_blocks)
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = local.public_subnets_cidr_blocks[count.index]
  assign_ipv6_address_on_creation = var.subnets.assign_ipv6_address_on_creation
  availability_zone               = var.subnets.availability_zone[count.index]

  # customer_owned_ipv4_pool =
  enable_dns64                                   = var.subnets.enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = var.subnets.enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = var.subnets.enable_resource_name_dns_a_record_on_launch
  # ipv6_cidr_block =
  /* ipv6_native                     = var.subnets.ipv6_native */
  /* map_customer_owned_ip_on_launch = var.subnets.map_customer_owned_ip_on_launch */
  map_public_ip_on_launch = var.subnets.map_public_ip_on_launch
  # outpost_arn =
  # private_dns_hostname_type_on_launch =

  tags = merge(local.common_plus_additional_tags,
    { Name = "${local.module_name}-public-subnet-${count.index}" }
  )
}


# Internet Gateway (IGW)
# Horizontally scaled, redundant, and highly available VPC component that allows communication between VPC and the internet.
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_plus_additional_tags,
    { Name = "${local.module_name}-igw" }
  )
}


# NAT Gateway
# A NAT gateway is a Network Address Translation (NAT) service. You can use a NAT gateway so that instances in a private subnet can connect to services outside your VPC but external services cannot initiate a connection with those instances.
# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
resource "aws_nat_gateway" "nat_gtw" {
  count         = length(local.public_subnets_cidr_blocks)
  allocation_id = aws_eip.eip_nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.common_plus_additional_tags,
    { Name = "${local.module_name}-nat-gtw-${count.index}" }
  )
}

# Elastic IP
# An Elastic IP address is a static IPv4 address designed for dynamic cloud computing.
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
resource "aws_eip" "eip_nat" {
  count = length(local.private_subnets_cidr_blocks)
  vpc   = true

  tags = merge(local.common_plus_additional_tags,
    { Name = "${local.module_name}-eip-${count.index}" }
  )
}

# Route tables
# A route table contains a set of rules, called routes, that determine where network traffic from your subnet or gateway is directed.
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_plus_additional_tags,
    { Name = "${local.module_name}-public-rtb" }
  )
}

# Private route table
resource "aws_route_table" "private" {
  count  = length(local.private_subnets_cidr_blocks)
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_plus_additional_tags,
    { Name = "${local.module_name}-private-rtb-${count.index}" }
  )
}

# Internet Gateway route
resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.public]
}

# NAT Gateway route
resource "aws_route" "nat_gtw_route" {
  count                  = length(aws_route_table.private)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gtw[count.index].id
  depends_on             = [aws_route_table.public]
}

# Public subnet association with public route table
resource "aws_route_table_association" "public_rtb_and_subnet_association" {
  count          = length(local.public_subnets_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private subnet association with private route tables
resource "aws_route_table_association" "private_rtb_and_subnet_association" {
  count          = length(local.private_subnets_cidr_blocks)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
