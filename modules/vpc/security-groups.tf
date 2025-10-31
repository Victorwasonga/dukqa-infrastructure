# DukQa Layered Security Group Design: Internet → ALB → Web → Database
# Traffic Flow: ALB-SG → Web-SG → DB-SG with SSH-SG for admin access

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.vpc_name}-alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Application Load Balancer"

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-alb-sg"
    Type = "ALB"
  })
}

# SSH/Bastion Security Group
resource "aws_security_group" "ssh" {
  name_prefix = "${var.vpc_name}-ssh-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for SSH/Bastion access"

  ingress {
    description = "SSH from Admin IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-ssh-sg"
    Type = "SSH/Bastion"
  })
}

# Web/App Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.vpc_name}-web-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Web/Application servers"

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh.id]
  }

  # EKS Node Group ports
  ingress {
    description = "EKS Node Group communication"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "EKS Control Plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-web-sg"
    Type = "Web/Application"
  })
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${var.vpc_name}-db-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Database servers"

  ingress {
    description     = "MySQL from Web/App servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    description     = "PostgreSQL from Web/App servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    description     = "SSH from Bastion (optional)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-db-sg"
    Type = "Database"
  })
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.vpc_name}-eks-cluster-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS cluster control plane"

  ingress {
    description     = "HTTPS from EKS nodes"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-eks-cluster-sg"
    Type = "EKS-Cluster"
  })
}