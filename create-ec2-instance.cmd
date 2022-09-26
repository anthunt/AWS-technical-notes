---
description: >-
  Windows Command line program to create a ec2 instance. this can help easy to
  make ec2 instance on windows with AWS CLI.
---

# CMD Script to make ec2 instance with AWS CLI

@REM ################################################################ @REM #\
@REM # Make EC2 INSTANCE with AWS Cli\
@REM #\
@REM ################################################################

@echo off setlocal

echo.\
echo This program can only create one EC2 instance at a time.\
echo.\
echo Creating EC2 INSTANCE with AWS CLI\
echo.

:SET\_AMI\_ID SET /P AMI\_ID="Set AMI ID : "

IF "%AMI\_ID%" == "" GOTO SET\_AMI\_ID

:SET\_INSTANCE\_TYPE SET /P INSTANCE\_TYPE="Set INSTANCE TYPE : "

IF "%INSTANCE\_TYPE%" == "" GOTO SET\_INSTANCE\_TYPE

:SET\_KEY\_NAME SET /P KEY\_NAME="Set KEY NAME : "

IF "%KEY\_NAME%" == "" GOTO SET\_KEY\_NAME

:SET\_SUBNET\_ID SET /P SUBNET\_ID="Set Subnet Id : "

IF "%SUBNET\_ID%" == "" GOTO SET\_SUBNET\_ID

:SET\_SG\_IDS SET /P SG\_IDS="Set Security Group Ids : "

IF "%SG\_IDS%" == "" GOTO SET\_SG\_IDS

:SET\_PRIV\_IP SET /P PRIV\_IP="Set Private Ip : "

IF "%PRIV\_IP%" == "" GOTO SET\_PRIV\_IP

:SET\_ROOT\_EBS\_SIZE SET /P ROOT\_EBS\_SIZE="Set Root EBS Size(G) : "

IF "%ROOT\_EBS\_SIZE%" == "" GOTO SET\_ROOT\_EBS\_SIZE

:SET\_ROOT\_EBS\_TYPE SET /P ROOT\_EBS\_TYPE="Set Root EBS Type : "

IF "%ROOT\_EBS\_TYPE%" == "" GOTO SET\_ROOT\_EBS\_TYPE

:SET\_INSTANCE\_TAGS\
echo.\
echo Tags Example : {Key=Name, Value=CLI\_TEST},{Key=Owner, Value=COMMON}\
echo. SET /P INSTANCE\_TAGS="Set Instance Tags : "

IF "%INSTANCE\_TAGS%" == "" GOTO SET\_INSTANCE\_TAGS

:SET\_VOLUME\_TAGS\
echo.\
echo Tags Example : {Key=Name, Value=CLI\_TEST},{Key=Owner, Value=COMMON}\
echo. SET /P VOLUME\_TAGS="Set Volume Tags : "

IF "%VOLUME\_TAGS%" == "" GOTO SET\_VOLUME\_TAGS

:SET\_PROFILE SET /P PROFILE\_NAME="Set Profile Name : "

IF "%PROFILE\_NAME%" == "" GOTO SET\_PROFILE

echo. \
echo Checking EBS RootDeviceName for AMI(%AMI\_ID%)\
echo. call aws ec2 describe-images --image-ids %AMI\_ID% --query "Images\[\*].{ID:RootDeviceName}" --output text --profile %PROFILE\_NAME% > tempRootDeviceName.txt

for /f %%i in ( tempRootDeviceName.txt ) do set ROOT\_DEVICE\_NAME=%%i

del tempRootDeviceName.txt

echo.\
echo ------------------------------------\
echo Review Input Values\
echo ------------------------------------\
echo.\
echo AMI ID = %AMI\_ID%\
echo Instance Type = %INSTANCE\_TYPE%\
echo Key Name = %KEY\_NAME%\
echo Subnet Id = %SUBNET\_ID%\
echo Security Group Ids = %SG\_IDS%\
echo Private Ip = %PRIV\_IP%\
echo Root EBS Size = %ROOT\_EBS\_SIZE%\
echo Root EBS Type = %ROOT\_EBS\_TYPE%\
echo ROOT Device Name = %ROOT\_DEVICE\_NAME%\
echo Instance Tags = %INSTANCE\_TAGS%\
echo Volume Tags = %VOLUME\_TAGS%\
echo Profile Name = %PROFILE\_NAME%\
echo.\
echo ------------------------------------\
echo.

:SET\_IS\_RUN\
SET /P IS\_RUN="you want to make?(Y/N) : "\
IF /i "%IS\_RUN%" == "Y" GOTO RUN\_CLI

IF /i "%IS\_RUN%" == "N" GOTO END\_INFO\
GOTO SET\_IS\_RUN

:RUN\_CLI\
echo.\
echo AWS Cli Running\
echo. aws ec2 run-instances --image-id %AMI\_ID% --count 1 --instance-type %INSTANCE\_TYPE% --key-name %KEY\_NAME% --security-group-ids %SG\_IDS% --subnet-id %SUBNET\_ID% --private-ip-address %PRIV\_IP% --block-device-mappings "\[{"DeviceName":"%ROOT\_DEVICE\_NAME%","Ebs":{"VolumeSize":%ROOT\_EBS\_SIZE%,"VolumeType":"%ROOT\_EBS\_TYPE%","DeleteOnTermination":true\}}]" --tag-specifications "ResourceType=instance,Tags=\[%INSTANCE\_TAGS%]" "ResourceType=volume,Tags=\[%VOLUME\_TAGS%]" --enable-api-termination --profile %PROFILE\_NAME%

:END\_INFO\
echo.\
echo Finished\
echo.

PAUSE
