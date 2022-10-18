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
```

```

## 3. Backing up Route53 with Python program
## 4. Intention to Lambda CloudWatch Events
