# modules/ec2/main.tf

# 1. ORCHESTRATE NETWORK FIREWALL GROUPS (Inbound/Outbound Rules)
resource "aws_security_group" "instance_sg" {
  name        = "${var.project_name}-sg"
  description = "Managed firewall policy rules for application environment hosts"
  vpc_id      = var.vpc_id

  # Administrative SSH access Channel — restricted strictly to your public IP
  ingress {
    description = "Isolated administrative SSH channel access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Flask API Port
  ingress {
    description = "Application custom interface engine exposure port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Frontend Web Client Port
  ingress {
    description = "Web interface standard entry target access port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus Scraping Metric Port
  ingress {
    description = "Metrics monitoring engine scraping collection port"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic to download software updates and pull images
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# 2. PROVISION IAM CONTAINER ACCESS ROLES
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ecr_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# 3. LOCATE LATEST BASELINE AMAZON LINUX 2023 IMAGE
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 4. MAP LOCAL ED25519 PUBLIC SSH IDENTITY FILE
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/devsecops_demo.pub")
}

# 5. ASSEMBLE LIVE COMPUTE INSTANCE SERVER
resource "aws_instance" "app_server" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.ec2_instance_type
  subnet_id            = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name             = aws_key_pair.ssh_key.key_name

  # Automation script to bootstrap environment dependencies on cold engine startup
  user_data = <<-EOF
              #!/bin/bash
              # Upgrade packages to patch security elements
              dnf update -y
              
              # Pull and initialize Docker daemon system engines
              dnf install -y docker git
              systemctl start docker
              systemctl enable docker
              
              # Map user identity rights into the system engine control group
              usermod -aG docker ec2-user
             
              # Install docker compose plugin
              mkdir -p /usr/local/lib/docker/cli-plugins
              curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
              -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

              # Clone your repo
              git clone https://github.com/jawad-glitch/DevSecOps-Pipeline.git /home/ec2-user/devsecops-pipeline
              chown -R ec2-user:ec2-user /home/ec2-user/devsecops-pipeline

              # Build workspace landing targets for local execution files
              mkdir -p /home/ec2-user/app
              EOF

  tags = {
    Name = "${var.project_name}-app-server"
  }
}
