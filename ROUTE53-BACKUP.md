# How to take AWS Route53 Backup

## 1. What is AWS Route53?

**From Wikipedia**

Amazon Route 53 (Route 53) is a scalable and highly available Domain Name System (DNS) service. Released on December 5, 2010, it is part of Amazon.com's cloud computing platform, Amazon Web Services (AWS). The name is a possible reference to U.S. Routes,and "53" is a reference to the TCP/UDP port 53, where DNS server requests are addressed.[3] In addition to being able to route users to various AWS services, including EC2 instances, Route 53 also enables AWS customers to route users to non-AWS infrastructure and to monitor the health of their application and its endpoints. Route 53's servers are distributed throughout the world. Amazon Route 53 supports full, end-to-end DNS resolution over IPv6. Recursive DNS resolvers on IPv6 networks can use either IPv4 or IPv6 transport to send DNS queries to Amazon Route 53

Customers create "hosted zones" that act as a container for four name servers. The name servers are spread across four different TLDs. Customers are able to add, delete, and change any DNS records in their hosted zones. Amazon also offers domain registration services to AWS customers through Route 53. Amazon provides an SLA of the service always being available at all times (100% available).

One of the key features of Route 53 is programmatic access to the service that allows customers to modify DNS records via web service calls. Combined with other features in AWS, this allows a developer to programmatically bring up a machine and point to components that have been created via other service calls such as those to create new S3 buckets or EC2 instances.

---

However, the AWS Route53 service does not have a backup service that supports itself. Instead, it provides a function to save a configuration file in JSON format through the AWS CLI or AWS SDK.

You need a way to back up and restore domain configuration information in case of an unexpected emergency.

The following describes how to create a backup file using the AWS CLI and AWS SDK, and how to create and manage backups periodically through Lambda by writing a Python program.

## 2. Backup CLI Route53

- Creating a JSON file containing Route53 configuration information via the AWS CLI
- Required Permissions
|- AmazonRoute53ReadOnlyAccess
|- AmazonRoute53DomainsReadOnlyAccess

### 1. Get HostedZone Ids
```
aws route53 list-hosted-zones --profile YOUR-PROFILE-NAME
```

### 2. Get RecordSet Configurations
```
aws route53 list-resource-record-sets — hosted-zone-id YOUR-HOSTED-ZONE-ID --output json --profile YOUR-PROFILE-NAME > route53-backup.json
```

### 3. Remove the next phrase at the beginning of json and the last "]}"
```
{
    "ResourceRecordSets": [
    
    ~~~~ Do not delete the middle part !! ~~~
    
    ]
}
```

### 4. Change the following phrases.

- Add the next phrase at the beginning of the middle part.
 
```
{
  "Action": "UPSERT",
  "ResourceRecordSet":
```

- All replace "}," to the next phrase

```
}},
{
  "Action": "UPSERT",
  "ResourceRecordSet":
```

- Add "}" at the end.


### 5. Add the following sentences before and after the remaining middle part.
```
{
            "Comment": "Route53 [Your Hosted Zone] Backup file",
            "Changes": [
            ~~~~ Add the middle part !! ~~~
            ]
}
```

## 3. Backing up Route53 with Python program for Lambda Function

- A lambda function that uploads all information composed of AWS Route53 HostedZone to S3 by writing the backup time as a file name.

```
import json
import boto3
import datetime
import logging

# Logger Configuration
logger = logging.getLogger()

# Logging Level Configuration
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    # Backup S3 Bucket 
    BackupBucketName = "Your S3 Bucket Name"
    
    # Backup start time
    now = datetime.datetime.now()
    # Backup start formatted day
    nowDate = now.strftime('%Y-%m-%d')
    # Backup start formatted hour, min, sec
    nowDatetime = now.strftime('%H-%M-%S')
    
    # Create Route53 client
    route53client = boto3.client('route53')
    
    # Create S3 client
    s3client = boto3.client("s3")
    
    # Get count response of Hosted Zones
    response = route53client.get_hosted_zone_count()
    
    # Set count variable for HostedZone count
    hostedZoneCount = response["HostedZoneCount"]
    
    # HostedZoneCount Logging
    logger.info("HostedZoneCount = {}".format(hostedZoneCount))
    
    # Get response HostedZones list
    response = route53client.list_hosted_zones()
    
    # Set HostedZones list variable
    HostedZones = list(response["HostedZones"])
    
    # HostedZones List Loop
    for zone in HostedZones:
        
        # Set HostedZoneId
        ZoneId = zone["Id"].replace("/hostedzone/", "")
        
        # Set HostedZone Name
        ZoneName = zone["Name"]
        
        # Se HostedZone Comment
        ZoneComment = zone["Config"]["Comment"]
        
        # Set Private/Public Zone
        IsPrivate = zone["Config"]["PrivateZone"]
        
        # Set folder name(S3 Prefix) (Private/Public)
        Forder = "PrivateZone" if IsPrivate else "PublicZone"
        
        ResourceRecordSets = []
        
        # Search resource record sets for HostedZone
        response = route53client.list_resource_record_sets(
            HostedZoneId=ZoneId
        )
        ResourceRecordSets.extend( list(response["ResourceRecordSets"]) )
        
        while response["IsTruncated"]:
        
            # Search resource record sets for HostedZone
            response = route53client.list_resource_record_sets(
                HostedZoneId = ZoneId
                , StartRecordName = response["NextRecordName"]
                , StartRecordType = response["NextRecordType"]
            )
            ResourceRecordSets.extend( list(response["ResourceRecordSets"]) )
        
        BackupSet = {
              "Comment" : nowDate + "/" + nowDatetime + "/" + Forder + "/" + ZoneName + " - [" + ZoneComment + "].json Backup Restore"
            , "Changes" : []
            
        }
        
        iRecord = 0;
        iFileCount = 1;
        
        for record in ResourceRecordSets:
            
            if record["Type"] != "NS" and record["Type"] != "SOA":
                
                if iRecord % 400 == 0:
                    
                    if iRecord > 0:
                        
                        ObjectKey = "Route53Backup/" + nowDate + "/" + nowDatetime + "/" + Forder + "/" + ZoneName + " - [" + ZoneComment + "]." + str(iFileCount) + ".json"
                        BodyBytes = str(BackupSet).replace("'", "\"").encode()
                        upload_s3(s3client, BackupBucketName, ObjectKey, BodyBytes)
                        iFileCount = iFileCount + 1
                        
                    BackupSet["Changes"].clear()
                    
                iRecord = iRecord + 1
                
                BackupSet["Changes"].append({
                    "Action" : "UPSERT"
                    , "ResourceRecordSet" : record
                })
        
        ObjectKey = "Route53Backup/" + nowDate + "/" + nowDatetime + "/" + Forder + "/" + ZoneName + " - [" + ZoneComment + "]." + str(iFileCount) + ".json"
        BodyBytes = str(BackupSet).replace("'", "\"").encode()
        upload_s3(s3client, BackupBucketName, ObjectKey, BodyBytes)
        
        logger.info("Export Completed - {}".format(ZoneName))
        
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }


def upload_s3(s3client, BackupBucketName, ObjectKey, BodyBytes):
    
    # Upload HostedZone Backup file to S3 backup bucket
    s3client.put_object(
        Bucket=BackupBucketName,
        Key=ObjectKey,
        Body=BodyBytes
    )
```

## 4. Intention to Lambda CloudWatch Events

1. Create a Python program for the lambda function created earlier as a lambda function
2. Create a Lambda function call event according to the backup cycle in CloudWatch Event



