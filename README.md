# deploy-aws-image

Tools we're going to use:

1. Ansible
2. aws-cli
3. Github
4. AWS
5. Repository (Docker and Docker-Compose)


### 1. Configure Repository Access on Github

**If your repository is public you can skip this part!**

1. Create new deploy keys.

```bash
$ cd github-deploy-keys
$ ssh-keygen -t rsa -b 4096 -C "myemail@super-email.com" -f $PWD/github-key.pem
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/arthuralvim/Work/deploy-aws-image/github-deploy-keys/github-key.pem.
Your public key has been saved in /Users/arthuralvim/Work/deploy-aws-image/github-deploy-keys/github-key.pem.pub.
The key fingerprint is:
...
```

2. Add the generated public key to the repository deploy keys.

![github-deploy-keys-part-1](https://github.com/arthuralvim/deploy-aws-image/blob/master/img/github-deploy-keys-1.png?raw=true)
![github-deploy-keys-part-2](https://github.com/arthuralvim/deploy-aws-image/blob/master/img/github-deploy-keys-2.png?raw=true)
![github-deploy-keys-part-3](https://github.com/arthuralvim/deploy-aws-image/blob/master/img/github-deploy-keys-3.png?raw=true)
![github-deploy-keys-part-4](https://github.com/arthuralvim/deploy-aws-image/blob/master/img/github-deploy-keys-4.png?raw=true)

### 2. Configure AWS User/Role

1. Create an user with programatically access (aws_access_key_id and aws_secret_access_key)
and the necessary permissions.

- EC2 permissions
- ECR permissions

![amazon-iam-1](https://github.com/arthuralvim/deploy-aws-image/blob/master/img/amazon-iam-1.png?raw=true)
![amazon-iam-2](https://github.com/arthuralvim/deploy-aws-image/blob/master/img/amazon-iam-2.png?raw=true)

2. Create a role with your application permissions (S3 + Cloudwatch). (optional)

3. Test your credentials and make sure your user has permissions to push/pull images.

### 4. Create New Machine

1. Generate a hash string for use as a tagging resource.
Ex: kZRaDCtdUIiFv9ApVmSX

2. Generate a key to access the machine.

```bash
$ aws ec2 create-key-pair --key-name tutorial-deploy-aws-image --query 'KeyMaterial' --output text > ~/.ssh/tutorial-deploy-aws-image.pem
```

3. Give necessary permissions to the key.

```bash
$ chmod 600 ~/.ssh/tutorial-deploy-aws-image.pem
```

> REVERSE:

> aws ec2 delete-key-pair --key-name tutorial-deploy-aws-image

4. Create a security group with the list of ports you need.

```bash
$ aws ec2 create-security-group --group-name tutorial-deploy-aws-image-sg --description "tutorial-deploy-aws-image-sg"
{
    "GroupId": "sg-0732f6c4f4554cccc"
}
$ aws ec2 authorize-security-group-ingress --group-name tutorial-deploy-aws-image-sg --protocol tcp --port 22 --cidr 0.0.0.0/0
$ aws ec2 authorize-security-group-ingress --group-name tutorial-deploy-aws-image-sg --protocol tcp --port 80 --cidr 0.0.0.0/0
$ aws ec2 authorize-security-group-ingress --group-name tutorial-deploy-aws-image-sg --protocol tcp --port 8000 --cidr 0.0.0.0/0
```

> REVERSE:

> aws ec2 delete-security-group --group-name tutorial-deploy-aws-image-sg

5. Create the instances.

```bash
$ aws ec2 run-instances --image-id ami-09479453c5cde9639 \
    --key-name tutorial-deploy-aws-image \
    --security-groups tutorial-deploy-aws-image-sg \
    --instance-type t3.medium \
    --placement AvailabilityZone=us-east-1a \
    --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":true}}]" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=kZRaDCtdUIiFv9ApVmSX},{Key=tutorial,Value=kZRaDCtdUIiFv9ApVmSX}]' 'ResourceType=volume,Tags=[{Key=tutorial,Value=kZRaDCtdUIiFv9ApVmSX}]' \
    --count 1
```

> REVERSE:

> aws ec2 describe-instances --filters "Name=tag:tutorial,Values=kZRaDCtdUIiFv9ApVmSX" --query "Reservations[*].Instances[*].InstanceId" --output text

> aws ec2 terminate-instances --instance-ids <i-00000000000000000>

6. Get the ip of the instance.

```bash
$ aws ec2 describe-instances --filters "Name=tag:tutorial,Values=kZRaDCtdUIiFv9ApVmSX" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
```

### 5. Provision Deploy Tools

```bash
pipenv install
```

```bash
pipenv shell
```

### 6. Update Machine Ansible Inventory

1. Open inventory and add the ip of the machines in the specified sections.

### 7. Test Deploy

```bash
make deploy.test
```

or

```bash
make deploy.tasks
```

### 8. Deploy

```bash
make deploy
```

### 9. MISSION COMPLETE

![MISSION COMPLETE!!!](https://media1.tenor.com/images/094aa61dc66ea2d7ee25c45943be30d3/tenor.gif?itemid=4849897 "MISSION COMPLETE!!!")

** THE END **
