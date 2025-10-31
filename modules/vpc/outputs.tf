output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ssh_security_group_id" {
  description = "ID of the SSH/Bastion security group"
  value       = aws_security_group.ssh.id
}

output "web_security_group_id" {
  description = "ID of the Web/Application security group"
  value       = aws_security_group.web.id
}

output "database_security_group_id" {
  description = "ID of the Database security group"
  value       = aws_security_group.database.id
}

output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.id
}

# Security Group Map for easy reference
output "security_groups" {
  description = "Map of all security group IDs"
  value = {
    alb      = aws_security_group.alb.id
    ssh      = aws_security_group.ssh.id
    web      = aws_security_group.web.id
    database = aws_security_group.database.id
    eks      = aws_security_group.eks_cluster.id
  }
}