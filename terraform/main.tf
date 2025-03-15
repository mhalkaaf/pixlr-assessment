# Create EC2 Instance

resource "aws_instance" "ec2-pixlr-server" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = aws_key_pair.ec2-keypair.key_name
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]

  # Install CloudWatch Agent using User Data to retrieve metrics data
  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y amazon-cloudwatch-agent
    sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOT
    {
      "metrics": {
        "metrics_collected": {
          "cpu": { "measurement": ["cpu_usage_idle"], "metrics_collection_interval": 60 },
          "disk": { "measurement": ["used_percent"], "metrics_collection_interval": 60 },
          "net": { "measurement": ["bytes_sent", "bytes_recv"], "metrics_collection_interval": 60 }
        }
      }
    }
    EOT
    sudo systemctl enable amazon-cloudwatch-agent
    sudo systemctl start amazon-cloudwatch-agent
  EOF

  tags = {
    Name        = "hello-world"
    Terraform   = "true"
    Environment = "lab"
  }
}

# Create Key Pair
resource "aws_key_pair" "ec2-keypair" {
  key_name   = "ssh-key"
  public_key = file("ssh-keys/ssh-key.pub")

  tags = {
    Name        = "ec2-server"
    Terraform   = "true"
    Environment = "lab"
  }
}

# Creating a security group to restrict/allow inbound connectivity
resource "aws_security_group" "ec2-security-group" {
  name        = "ec2-security-group"
  description = "Allow SSH traffic"

  ingress {
    description = "Allow SSH only from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress_cidr_blocks
  }

  ingress {
    description = "Allow HTTP Port for Web Service to Public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all for outbond traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ec2-server-sg"
    Terraform   = "true"
    Environment = "lab"
  }
}

# Create CloudWatch Log Group for retrieving logs
resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name              = "/aws/ec2/pixlr-server"
  retention_in_days = 7 # How many days that data need to be stored
}

# Create S3 Policy for EC2
resource "aws_iam_policy" "ec2-s3-policy" {
  name        = "EC2-S3-Bucket-Access-Policy"
  description = "Provides permission to access S3"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# CloudWatch Agent IAM Policy to publish logs and metrics to CloudWatch
resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name        = "CloudWatchAgentServerPolicy"
  description = "Allows EC2 instances to publish logs and metrics to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach S3 Policies into IAM Role
resource "aws_iam_policy_attachment" "ec2-policies-role-attachment" {
  name       = "ec2-policies-role-attachment"
  roles      = [aws_iam_role.ec2-role.name]
  policy_arn = aws_iam_policy.ec2-s3-policy.arn
}

# Attach CloudWatch IAM Policy to EC2 Role
resource "aws_iam_policy_attachment" "cloudwatch_policy_attachment" {
  name       = "cloudwatch-policy-attachment"
  roles      = [aws_iam_role.ec2-role.name]
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

#Create an IAM Role
resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach IAM Role into IAM Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2-role.name
}