
# Pixlr Assessment

This project is Pixlr Assessment

## Challenge 1, 2, & 3

For this assessment, I used Terraform as an Infrastructure as Code (IaC) tool to automate the provisioning of AWS EC2 instances and related resources.

The Terraform configuration deploys the following AWS resources:

- EC2 Instance (Virtual machine instance).
- EC2 Key Pair (For secure SSH access).
- EC2 Security Group (To control inbound/outbound traffic).
- CloudWatch Log Group (For logging and monitoring).
- IAM Policies (To grant permissions for accessing S3 and publishing logs to CloudWatch).
- IAM Policy Attachments (Binding IAM policies to roles).
- IAM Role (To assign permissions to the EC2 instance).
- IAM Instance Profile (To associate the IAM role with the EC2 instance).

### Monitoring and Metrics Explanation

#### CPU Usage (cpu_usage_idle)
- This parameter is used to monitoring The percentage of CPU time that remains idle (not used).
- High idle time indicates low resource utilization, which may suggest over-provisioning of compute resources.
- Consistently low idle time (near 0%) indicates high CPU usage, which may lead to degraded application performance.
- This parameter helps in optimizing resource allocation and cost by determining if the instance is over/under-utilized.
- Alerts can be set up to notify when CPU usage is consistently high, allowing for scaling or optimization.

#### Disk Usage (used_percent)

- This monitoring metrics is used to check the percentage of disk space being used.
- Running out of disk space can lead to application failures, logging issues, and degraded performance.
- High disk usage may indicate excessive logging or data accumulation that requires cleanup.
- Proactive alerts can be set up to warn when disk usage crosses a threshold, preventing application downtime.
- This monitoring metrics helps identify inefficiencies in storage management, allowing for optimizations like log rotation or resizing.

#### Network Traffic (bytes_sent, bytes_recv)
- This monitoring metric is used to monitor the amount of data sent and received by the instance.
- This is important because high network traffic can indicate heavy application usage or potential security issues (DDoS attacks, data exfiltration).
- Low or no traffic might suggest application failures, networking issues, or low demand.
- This monitoring metric helps in identifying abnormal network patterns that may indicate issues with the application or network bottlenecks.
- It's Supports capacity planning by analyzing traffic trends to determine if scaling is needed.

### Security Best Practices Implemented
To ensure a secure and well-managed infrastructure, the following best practices were applied:

#### Terraform State Management
- Terraform state files are stored in Amazon S3, which provides encryption at rest, ensuring that sensitive information in the state file remains secure.

#### Secure Handling of Sensitive Variables
- Input variables are stored in terraform.tfvars, keeping sensitive values like passwords and secrets more secure.
- .gitignore includes terraform.tfvars to prevent sensitive data from being uploaded to a GitHub repository
- Here's the example of terraform.tfvars that I applied during terraform execution

```bash
  aws_region              = "us-east-1"
  ec2_instance_type       = "t3.small"
  ec2_ami_id              = "ami-04aa00acb1165b32a"
  ssh_ingress_cidr_blocks = ["104.28.250.138/32"]
```

#### Restricted SSH Access
- The security group is configured to allow SSH access only from my public IP (104.28.250.138/32).
- This prevents unauthorized access by blocking all other incoming SSH connections.

#### Cost-effective Resource
- I choose t3.small instance because of its balance of performance and cost-effectiveness, as this is a test environment.

#### Principle of Least Privilege
- Enforce to implement least priviledged by providing IAM Policies that attached to EC2 instance to access only spesific resource, like accessing S3 and publish logs from ec2 cloudwatch agent to AWS Cloud Watch. This approach minimizes security risks by restricting the server from accessing unnecessary resources.
- Using IAM roles avoids storing static credentials inside the instance.
- IAM Role of Cloudwatch agent to publish and store logs is necessary for providing real-time monitoring of system health, including CPU, memory, disk usage, and network traffic.

#### Cost-effective Resource
- Use feature of terraform like terraform modules for reusable code, and terraform workspaces for multiple environment. since its only one environment, I'am not using modules and terraform workspaces.

## Challenge 4

I chose GitHub Actions instead of Jenkins and GitLab CI/CD for the CI/CD pipeline due to the following benefits:
- Since the source code is hosted on GitHub, GitHub Actions provides native integration, eliminating the need for additional setup or webhooks, unlike Jenkins and GitLab CI/CD, which require external connections.
- GitHub Actions uses YAML-based workflows, making it easier to define and manage pipelines directly within the repository. In contrast, Jenkins requires managing separate servers and plugins, which adds complexity.
- Unlike Jenkins, which requires a dedicated server and maintenance, GitHub Actions is a fully managed CI/CD solution, reducing the need for infrastructure setup, monitoring, and scaling.
- For open-source projects, GitHub Actions provides free CI/CD minutes, while Jenkins requires hosting, which incurs server costs.

![Image](https://github.com/user-attachments/assets/ca5de8e4-19cb-4475-87fd-dc5a36580566)