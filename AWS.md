# AWS bastion host EC2 instance

Below are instructions for using the AWS CLI to provison an ubuntu virtual machine on Azure to use for the cluster, keptn, and application setup.

# Create bastion host

These instructions assume you have an AWS account and have the AWS CLI installed and configured locally.
 
You can also make the bastion host from the console and then continue with the steps to connect using ssh.  But you must use this image as to have the install scripts be compatible:
* Ubuntu Server 16.04 LTS (HVM), SSD Volume Type (64-bit x86)

## 1. Install and configure the AWS cli

These instructions assume you have an AWS account and have the AWS CLI installed and configured locally.

See [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) for local CLI installation and configuration.

See [this article](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/) for For help access keys

Once installed, run this command to configure the cli:

```aws configure```

At the prompt, 
* enter your AWS Access Key ID
* enter your AWS Secret Access Key ID
* enter Default region name, for example us-east-1
* enter Default output format, enter json

When complete, run this command ```aws ec2 describe-instances``` to see your VMs

## 2. Create bastion host EC2 instance using aws cli

Run this command to create the VM.  You need to adjust value for ssh key name.  You can optionally adjust values for tags and region. [aws docs](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html)


```
# adjust these variables
export SSH_KEY=<your key pair name, see ec2 key pairs in aws portal> 
export RESOURCE_PREFIX=<example your last name>
# NOTE: The AMI ID may vary my region. This is the AMI for us-east-1
export VM_REGION=us-east-1
export AMI_ID=ami-0cfee17793b08a293

# leave these values as they are
export AWS_HOST_NAME="$RESOURCE_PREFIX"-keptn-orders-bastion
export AWS_SECURITY_GROUP_NAME="$RESOURCE_PREFIX"-keptn-orders-bastion-group

# create-security-group
aws ec2 create-security-group \
  --group-name $AWS_SECURITY_GROUP_NAME \
  --description "Used by keptn-orders bastion host"

# get the new security-group id
export AWS_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=$AWS_SECURITY_GROUP_NAME" \
  --query "SecurityGroups[0].GroupId" \
  --output text)

# update create-security-group with inbound rule to support ssh
aws ec2 authorize-security-group-ingress \
  --group-id "$AWS_SECURITY_GROUP_ID" \
  --protocol tcp \
  --port 22 \
  --cidr "0.0.0.0/0"

# update create-security-group with inbound rule to support bridge
aws ec2 authorize-security-group-ingress \
  --group-id "$AWS_SECURITY_GROUP_ID" \
  --protocol tcp \
  --port 80 \
  --cidr "0.0.0.0/0"

# provision the host
aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --count 1 \
  --security-group-ids "$AWS_SECURITY_GROUP_ID" \
  --instance-type t2.micro \
  --key-name $SSH_KEY  \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$AWS_HOST_NAME}]" \
  --region $VM_REGION
```

## 3. SSH into the bastion host EC2 instance 

From the aws web console, get the connection string for the VM. Run this command to SSH to the new VM.
```
ssh -i "<your local pem file>.pem" ubuntu@<your host>.compute.amazonaws.com
```

## 4. Clone the Orders setup repo

Within the VM, run these commands to clone the setup repo.

```
git clone --branch 0.4.0 https://github.com/keptn-orders/keptn-orders-setup.git --single-branch
cd keptn-orders-setup
```

Finally, proceed to the [Provision Cluster, Install Keptn, and onboard the Orders application](README.md#installation-scripts-from-setup-menu) step.

# Delete the bastion host

## Option 1 - delete using azure cli

From your laptop, run these commands to delete the EC2 instance

```
# adjust these variables
export RESOURCE_PREFIX=<example your last name>

# leave these values
export AWS_HOST_NAME="$RESOURCE_PREFIX"-keptn-orders-bastion
export AWS_SECURITY_GROUP_NAME="$RESOURCE_PREFIX"-keptn-orders-bastion-group

# get bastion host instance id
export AWS_INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$AWS_HOST_NAME" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)
# terminate instance
aws ec2 terminate-instances --instance-ids $AWS_INSTANCE_ID

# allow for VM to be removed
sleep 30

# get the security-group id
export AWS_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=$AWS_SECURITY_GROUP_NAME" \
  --query "SecurityGroups[0].GroupId" \
  --output text)

# delete the security group
aws ec2 delete-security-group --group-id $AWS_SECURITY_GROUP_ID
```

## Option 2 - delete from the Azure console

From the aws web console, choose VM and terminate it and choose the security group and delete it.