# aws-cloudformation

## Create AWS Resources

System Manager

```
aws ssm put-parameter --name "/myproject/sns/email" --type String --value ${EMAIL}
aws ssm put-parameter --name "/myproject/app/rails-master-key" --type String --value ${RAILS_MASTER_KEY}
aws ssm put-parameter --name "/myproject/db/host" --type String --value ${DATABASE_HOST}
aws ssm put-parameter --name "/myproject/db/username" --type String --value ${DATABASE_USERNAME}
aws ssm put-parameter --name "/myproject/db/password" --type String --value ${DATABASE_PASSWORD}
aws ssm put-parameter --name "/myproject/github/oauth-token" --type String --value ${GITHUB_OAUTH_TOKEN}
aws ssm put-parameter --name "/myproject/github/secret" --type String --value ${GITHUB_SECRET}
aws ssm put-parameter --name "/myproject/redis/url" --type String --value ${REDIS_URL}
aws ssm put-parameter --name "/myproject/ip/home" --type String --value ${IP_HOME}
aws ssm put-parameter --name "/myproject/ip/office" --type String --value ${IP_OFFICE}
aws ssm put-parameter --name "/myproject/ip/office-guest" --type String --value ${IP_OFFICE_GUEST}
```

VPC

```
./cloudformation/create.sh myproject vpc-3azs
```

VPC NatGateway

```
./cloudformation/create.sh myproject vpc-nat-gateway
```

Route53 Hosted zone

```
./cloudformation/create.sh myproject vpc-zone-public
```

SNS Topic

```
./cloudformation/create.sh myproject alert
```

Security Group

```
./cloudformation/create.sh myproject client-sg
```

SSH bastion host

```
./cloudformation/create.sh myproject vpc-ssh-bastion
```

Describe ElastiCache Redis versions

```
aws elasticache describe-cache-engine-versions --engine redis --query "CacheEngineVersions[].EngineVersion"
```

ElastiCache Redis

```
./cloudformation/create.sh myproject elasticache-redis
```

Describe RDS Aurora versions

```
aws rds describe-db-engine-versions --engine aurora-mysql --query DBEngineVersions[].EngineVersion
```

RDS Aurora

```
./cloudformation/create.sh myproject rds-aurora
```

KMS Key

```
./cloudformation/create.sh myproject kms-key
```

RDS Aurora Serverless

```
./cloudformation/create.sh myproject rds-aurora-serverless
```

ECR

```
./cloudformation/create.sh myproject ecr
```

ECS cluster

```
./cloudformation/create.sh myproject ecs-cluster
```

ECS service cluster

```
./cloudformation/create.sh myproject ecs-service-cluster-alb
```

ECS Spot Fleet

```
./cloudformation/create.sh myproject ecs-spot-alb
```

SecurityGroup for CloudFront

```
./cloudformation/create.sh myproject cloudfront-sg
```

WAF for CloudFront

```
./cloudformation/create.sh myproject waf
```

ECS Spot Fleet without ALB

```
./cloudformation/create.sh myproject ecs-spot
```

Fargate cluster

```
./cloudformation/create.sh myproject fargate-cluster
```

Fargate service cluster

```
./cloudformation/create.sh myproject fargate-service-cluster-alb
```

CodePipeline

```
./cloudformation/create.sh myproject codepipeline
```

Setup Database for EC2

```
CLUSTER=$(aws cloudformation describe-stack-resource --profile training --stack-name myproject-ecs-spot --logical-resource-id ECSCluster --query StackResourceDetail.PhysicalResourceId --output text)

TASK_DEFINITION=$(aws cloudformation describe-stack-resource --profile training --stack-name myproject-fargate-service-cluster-alb --logical-resource-id TaskDefinition --query StackResourceDetail.PhysicalResourceId --output text)

aws ecs run-task \
  --profile training \
  --cluster "$CLUSTER" \
  --task-definition "myproject-ecs-spot-db-migrate" \
  --overrides '{"containerOverrides": [{"name": "app", "command": ["rake", "db:create"]}]}' \
  --launch-type EC2

aws ecs wait tasks-stopped --profile training --tasks ${TASK_ARN} --cluster ${CLUSTER}
```

Setup Database for Fargate

```
CLUSTER=$(aws cloudformation describe-stack-resource --profile training --stack-name myproject-fargate-cluster --logical-resource-id Cluster --query StackResourceDetail.PhysicalResourceId --output text)

TASK_DEFINITION=$(aws cloudformation describe-stack-resource --profile training --stack-name myproject-fargate-service-cluster-alb --logical-resource-id TaskDefinition --query StackResourceDetail.PhysicalResourceId --output text)

TASK_ARN=$(aws ecs run-task \
  --profile training \
  --cluster "$CLUSTER" \
  --task-definition "$TASK_DEFINITION" \
  --overrides '{"containerOverrides": [{"name": "app", "command": ["rake", "db:setup"]}]}' \
  --launch-type FARGATE \
  --network-configuration 'awsvpcConfiguration={subnets=[subnet-0848c3ac7d2287561],securityGroups=[sg-0f331632e04839ff6],assignPublicIp=ENABLED}' | jq -r '.tasks[0].taskArn')

aws ecs wait tasks-stopped --profile training --tasks ${TASK_ARN} --cluster ${CLUSTER}
```

## Update AWS Resources

VPC

```
./cloudformation/create-change-set.sh myproject vpc-3azs
./cloudformation/execute-change-set.sh myproject vpc-3azs
```

VPC NatGateway

```
./cloudformation/create-change-set.sh myproject vpc-nat-gateway
./cloudformation/execute-change-set.sh myproject vpc-nat-gateway
```

Route53 Hosted zone

```
./cloudformation/create-change-set.sh myproject vpc-zone-public
./cloudformation/execute-change-set.sh myproject vpc-zone-public
```

SNS Topic

```
./cloudformation/create-change-set.sh myproject alert
./cloudformation/execute-change-set.sh myproject alert
```

Security Group

```
./cloudformation/create-change-set.sh myproject client-sg
./cloudformation/execute-change-set.sh myproject client-sg
```

SSH bastion host

```
./cloudformation/create-change-set.sh myproject vpc-ssh-bastion
./cloudformation/execute-change-set.sh myproject vpc-ssh-bastion
```

Describe ElastiCache Redis versions

```
aws elasticache describe-cache-engine-versions --engine redis --query "CacheEngineVersions[].EngineVersion"
```

ElastiCache Redis

```
./cloudformation/create-change-set.sh myproject elasticache-redis
./cloudformation/execute-change-set.sh myproject elasticache-redis
```

Describe RDS Aurora versions

```
aws rds describe-db-engine-versions --engine aurora-mysql --query DBEngineVersions[].EngineVersion
```

RDS Aurora

```
./cloudformation/create-change-set.sh myproject rds-aurora
./cloudformation/execute-change-set.sh myproject rds-aurora
```

RDS Aurora Serverless

```
./cloudformation/create-change-set.sh myproject rds-aurora-serverless
./cloudformation/execute-change-set.sh myproject rds-aurora-serverless
```

ECR

```
./cloudformation/create-change-set.sh myproject ecr
./cloudformation/execute-change-set.sh myproject ecr
```

ECS cluster

```
./cloudformation/create-change-set.sh myproject ecs-cluster
./cloudformation/execute-change-set.sh myproject ecs-cluster
```

ECS service cluster

```
./cloudformation/create-change-set.sh myproject ecs-service-cluster-alb
./cloudformation/execute-change-set.sh myproject ecs-service-cluster-alb
```

ECS Spot Fleet

```
./cloudformation/create-change-set.sh myproject ecs-spot-alb
./cloudformation/execute-change-set.sh myproject ecs-spot-alb
```

SecurityGroup for CloudFront

```
./cloudformation/create-change-set.sh myproject cloudfront-sg
./cloudformation/execute-change-set.sh myproject cloudfront-sg
```

WAF for CloudFront

```
./cloudformation/create-change-set.sh myproject waf
./cloudformation/execute-change-set.sh myproject waf
```

ECS Spot Fleet without ALB

```
./cloudformation/create-change-set.sh myproject ecs-spot
./cloudformation/execute-change-set.sh myproject ecs-spot
```

Fargate cluster

```
./cloudformation/create-change-set.sh myproject fargate-cluster
./cloudformation/execute-change-set.sh myproject fargate-cluster
```

Fargate service cluster

```
./cloudformation/create-change-set.sh myproject fargate-service-cluster-alb
./cloudformation/execute-change-set.sh myproject fargate-service-cluster-alb
```

CodePipeline

```
./cloudformation/create-change-set.sh myproject codepipeline
./cloudformation/execute-change-set.sh myproject codepipeline
```

## Delete AWS Resources

VPC

```
./cloudformation/delete.sh myproject vpc-3azs
```

VPC NatGateway

```
./cloudformation/delete.sh myproject vpc-nat-gateway
```

Route53 Hosted zone

```
./cloudformation/delete.sh myproject vpc-zone-public
```

SNS Topic

```
./cloudformation/delete.sh myproject alert
```

Security Group

```
./cloudformation/delete.sh myproject client-sg
```

SSH bastion host

```
./cloudformation/delete.sh myproject vpc-ssh-bastion
```

ElastiCache Redis

```
./cloudformation/delete.sh myproject elasticache-redis
```

RDS Aurora

```
./cloudformation/delete.sh myproject rds-aurora
```

RDS Aurora Serverless

```
./cloudformation/delete.sh myproject rds-aurora-serverless
```

ECR

```
./cloudformation/delete.sh myproject ecr
```

ECS cluster

```
./cloudformation/delete.sh myproject ecs-cluster
```

ECS service cluster

```
./cloudformation/delete.sh myproject ecs-service-cluster-alb
```

ECS Spot Fleet

```
./cloudformation/delete.sh myproject ecs-spot-alb
```

SecurityGroup for CloudFront

```
./cloudformation/delete.sh myproject cloudfront-sg
```

WAF for CloudFront

```
./cloudformation/delete.sh myproject waf
```

ECS Spot Fleet without ALB

```
./cloudformation/delete.sh myproject ecs-spot
```

Fargate cluster

```
./cloudformation/delete.sh myproject fargate-cluster
```

Fargate service cluster

```
./cloudformation/delete.sh myproject fargate-service-cluster-alb
```

CodePipeline

```
./cloudformation/delete.sh myproject codepipeline
```

## Elastic Beanstalk

If you want to use Elastic Beanstalk, follow the steps below.

Install awsebcli

```
pip install awsebcli
```

Create an application

```
eb init -p docker-18.06.1-ce
```

Make sure your configuration

```
cat .elasticbeanstalk/config.yml
```

Create your environment

```
eb create
```

Your application might not work, see your logs

```
eb logs
```

Create Database at the Elastic Beanstalk Configuration Console

- After creating Database, note your Database Endpoint

Set environment variables

```
eb setenv \
  RAILS_ENV=production \
  RAILS_SERVE_STATIC_FILES=1 \
  RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
  DATABASE_HOST=${DATABASE_HOST}
  DATABASE_PASSWORD=${DATABASE_PASSWORD} \
  REDIS_URL=${REDIS_URL}
```

Make sure your environment variables

```
eb printenv
```

Configure following settings on the management console

- Make sure Load Balancer's Health Check Path '/health_checks'
- Execute ``docker exec `docker ps -l -q` rake db:create`` as root user on the EC2 instance 

Deploy changes

```
eb deploy [--staged]
```

# How to allow traffic only from CloudFront 

See also https://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html

```
curl -O https://ip-ranges.amazonaws.com/ip-ranges.json
jq -r '.prefixes[] | select(.service=="CLOUDFRONT")' < ip-ranges.json | jq -r .ip_prefix > ip-ranges.txt
split -l 60 ip-ranges.txt ip-ranges
```

Edit cloudfront-sg.yaml with this command's outputs

```
while read line
do
  cat << EOS
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: $line
EOS
done < ./ip-rangesaa > cloudformationa.txt

while read line
do
  cat << EOS
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: $line
EOS
done < ./ip-rangesab > cloudformationb.txt
```

Edit `.ebextensions/01-resources.config`
