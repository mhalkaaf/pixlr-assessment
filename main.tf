# Create EC2 Instance

resource "aws_instance" "ec2-pixlr-server" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = aws_key_pair.ec2-keypair.key_name
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]
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

# Create Iam Policy for Iam Role
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


#Create an IAM Role
resource "aws_iam_role" "ec2-s3-role" {
  name = "ec2-s3-role"

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

# Attach IAM Policies into IAM Role
resource "aws_iam_policy_attachment" "ec2-policies-role-attachment" {
  name       = "ec2-policies-role-attachment"
  roles      = [aws_iam_role.ec2-s3-role.name]
  policy_arn = aws_iam_policy.ec2-s3-policy.arn
}

# Attach IAM Role into IAM Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2-s3-role.name
}