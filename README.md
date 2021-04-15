AWS CloudFormation Backed SNS
=============================

This Terraform module sets up the infrastructure for SNS Backed Cloudformation template in AWS.


Install
-------

```shell
pip install -r requirements.txt -t ./code
```
The file [requirements.txt](./requirements.txt) includes all required libraries for the python code.


Usage
-----

```hcl
module "cf_custom_lambda_sns" {
  source = "<insert_repo_link_here>"
}
```

Output
-------

 - `cf_backed_sns_arn` - ARN to be used in CloudFormation template as custom resource.

Understanding Cloudformation Template Usage
-------------------------------------------

```yaml
Parameters:
  CustomSNSTopicARN:
    Type: String
    Description: Enter cf_backed_sns_arn here 

Resources:
  CustomSNS:
    Type: Custom::SNSInvoker
    Properties:
      ServiceToken: !Ref CustomSNSTopicARN
      # add your ResourceProperties here
      
Outputs:
  Status:
    Value: !GetAtt CustomSNS.Status
```

Folder Structure
-------------------------------------
The folder [code](./code) includes code for lambda.

```bash
$ tree
.
├── main.tf
├── outputs.sh
├── requirements.txt
├── .gitignore
└── code
    └── lambda_function.py
```

Author
======

saif.ali@sudoconsultants.com

License
=======

[MIT](./LICENSE)