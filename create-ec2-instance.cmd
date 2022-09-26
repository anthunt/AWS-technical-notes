---
description: >-
  Windows Command line program to create a ec2 instance. this can help easy to
  make ec2 instance on windows with AWS CLI.
---

# 1. CMD Script to make ec2 instance with AWS CLI

```batch
@REM ################################################################ 
@REM #
@REM # Make EC2 INSTANCE with AWS Cli
@REM #
@REM ################################################################
@echo off setlocal
echo.
echo This program can only create one EC2 instance at a time.
echo.
echo Creating EC2 INSTANCE with AWS CLI
echo.
:SET_AMI_ID SET /P AMI_ID="Set AMI ID : "
IF "%AMI_ID%" == "" GOTO SET_AMI_ID
:SET_INSTANCE_TYPE SET /P INSTANCE_TYPE="Set INSTANCE TYPE : "
IF "%INSTANCE_TYPE%" == "" GOTO SET_INSTANCE_TYPE
:SET_KEY_NAME SET /P KEY_NAME="Set KEY NAME : "
IF "%KEY_NAME%" == "" GOTO SET_KEY_NAME
:SET_SUBNET_ID SET /P SUBNET_ID="Set Subnet Id : "
IF "%SUBNET_ID%" == "" GOTO SET_SUBNET_ID
:SET_SG_IDS SET /P SG_IDS="Set Security Group Ids : "
IF "%SG_IDS%" == "" GOTO SET_SG_IDS
:SET_PRIV_IP SET /P PRIV_IP="Set Private Ip : "
IF "%PRIV_IP%" == "" GOTO SET_PRIV_IP
:SET_ROOT_EBS_SIZE SET /P ROOT_EBS_SIZE="Set Root EBS Size(G) : "
IF "%ROOT_EBS_SIZE%" == "" GOTO SET_ROOT_EBS_SIZE
:SET_ROOT_EBS_TYPE SET /P ROOT_EBS_TYPE="Set Root EBS Type : "
IF "%ROOT_EBS_TYPE%" == "" GOTO SET_ROOT_EBS_TYPE
:SET_INSTANCE_TAGS
echo.
echo Tags Example : {Key=Name, Value=CLI_TEST},{Key=Owner, Value=COMMON}
echo. SET /P INSTANCE_TAGS="Set Instance Tags : "
IF "%INSTANCE_TAGS%" == "" GOTO SET_INSTANCE_TAGS
:SET_VOLUME_TAGS
echo.
echo Tags Example : {Key=Name, Value=CLI_TEST},{Key=Owner, Value=COMMON}
echo. SET /P VOLUME_TAGS="Set Volume Tags : "
IF "%VOLUME_TAGS%" == "" GOTO SET_VOLUME_TAGS
:SET_PROFILE SET /P PROFILE_NAME="Set Profile Name : "
IF "%PROFILE_NAME%" == "" GOTO SET_PROFILE
echo. 
echo Checking EBS RootDeviceName for AMI(%AMI_ID%)
echo. call aws ec2 describe-images --image-ids %AMI_ID% --query "Images[*].{ID:RootDeviceName}" --output text --profile %PROFILE_NAME% > tempRootDeviceName.txt
for /f %%i in ( tempRootDeviceName.txt ) do set ROOT_DEVICE_NAME=%%i
del tempRootDeviceName.txt
echo.
echo ------------------------------------
echo Review Input Values
echo ------------------------------------
echo.
echo AMI ID = %AMI_ID%
echo Instance Type = %INSTANCE_TYPE%
echo Key Name = %KEY_NAME%
echo Subnet Id = %SUBNET_ID%
echo Security Group Ids = %SG_IDS%
echo Private Ip = %PRIV_IP%
echo Root EBS Size = %ROOT_EBS_SIZE%
echo Root EBS Type = %ROOT_EBS_TYPE%
echo ROOT Device Name = %ROOT_DEVICE_NAME%
echo Instance Tags = %INSTANCE_TAGS%
echo Volume Tags = %VOLUME_TAGS%
echo Profile Name = %PROFILE_NAME%
echo.
echo ------------------------------------
echo.
:SET_IS_RUN
SET /P IS_RUN="you want to make?(Y/N) : "
IF /i "%IS_RUN%" == "Y" GOTO RUN_CLI
IF /i "%IS_RUN%" == "N" GOTO END_INFO
GOTO SET_IS_RUN
:RUN_CLI
echo.
echo AWS Cli Running
echo. aws ec2 run-instances --image-id %AMI_ID% --count 1 --instance-type %INSTANCE_TYPE% --key-name %KEY_NAME% --security-group-ids %SG_IDS% --subnet-id %SUBNET_ID% --private-ip-address %PRIV_IP% --block-device-mappings "[{"DeviceName":"%ROOT_DEVICE_NAME%","Ebs":{"VolumeSize":%ROOT_EBS_SIZE%,"VolumeType":"%ROOT_EBS_TYPE%","DeleteOnTermination":true}}]" --tag-specifications "ResourceType=instance,Tags=[%INSTANCE_TAGS%]" "ResourceType=volume,Tags=[%VOLUME_TAGS%]" --enable-api-termination --profile %PROFILE_NAME%
:END_INFO
echo.
echo Finished
echo.
PAUSE
```

