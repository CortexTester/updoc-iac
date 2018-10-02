#!/bin/bash -ex

echo "update clouldformat to s3"
aws s3 cp aws-swarm.json s3://updoc-iac/aws-swarm.json --acl public-read

echo "building up docker swarm in aws..."
aws cloudformation create-stack   \
      --capabilities CAPABILITY_IAM \
      --template-url https://s3-us-west-2.amazonaws.com/updoc-iac/aws-swarm.json\
      --stack-name updoc \
      --parameters ParameterKey=ClusterSize,ParameterValue=1 \
        ParameterKey=EnableCloudStorEfs,ParameterValue=yes \
        ParameterKey=EnableCloudWatchLogs,ParameterValue=yes \
        ParameterKey=EnableEbsOptimized,ParameterValue=no \
        ParameterKey=EnableSystemPrune,ParameterValue=no \
        ParameterKey=EncryptEFS,ParameterValue=false \
        ParameterKey=InstanceType,ParameterValue=t2.micro \
        ParameterKey=KeyName,ParameterValue=updoc \
        ParameterKey=ManagerDiskSize,ParameterValue=20 \
        ParameterKey=ManagerDiskType,ParameterValue=standard \
        ParameterKey=ManagerInstanceType,ParameterValue=t2.micro \
        ParameterKey=ManagerSize,ParameterValue=1 \
        ParameterKey=WorkerDiskSize,ParameterValue=20 \
        ParameterKey=WorkerDiskType,ParameterValue=standard 

while [[ `aws cloudformation describe-stacks --stack-name updoc --query Stacks[0].StackStatus` != *"COMPLETE"* ]]
do
    status = $(aws cloudformation describe-stacks --stack-name updoc --query Stacks[0].StackStatus)
    echo `status is $status`
	sleep 5
done

aws cloudformation describe-stacks --stack-name updoc --query Stacks[0].Outputs