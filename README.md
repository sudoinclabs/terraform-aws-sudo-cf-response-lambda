AWS CloudFormation Backed SNS
=============================

This Terraform module sets up the infrastructure for SNS Backed Cloudformation template in AWS.

Module Flow: Provision resources by applying this module, you will get an output `cf_backed_sns_arn`
use this SNS arn in cloudformation template as `ServiceToken` for the custom resource.

The module creates a Lambda function, SNS topic and a subscription to invoke lambda, along with required roles and policies.

Usage
-----

```hcl
module "cf_custom_lambda_sns" {
  source  = "sudoinclabs/sudo-cf-response-lambda/aws"
  version = "1.0.3"
}
```

With custom lambda function (see below for further instructions.)

```hcl
module "cf_custom_lambda_sns" {
  source  = "sudoinclabs/sudo-cf-response-lambda/aws"
  version = "1.0.3"

  lambda_code_path = "code"
  lambda_env_vars = {}
}
```

Output
-------

- `cf_backed_sns_arn` - Arn of the SNS backed CloudFormation custom resource.
- `cf_backed_lambda_role_name` - Role name of the lambda function.
- `cf_backed_lambda_arn` - Arn of the lambda function.

Custom Lambda Function
-------

In your terraform root directory.

```shell
mkdir code
pip install crhelper -t ./code
```

Create your lambda function file called: lambda_function.py

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
├── main.tf                   # Contains HCL for provisioning the resources
├── outputs.tf                # Contains output from the module
├── requirements.txt          # Install required libraries for the lambda function
├── .gitignore
└── code
    └── lambda_function.py    # Use crhelper to parse the SNS event from CF custom resource and return status.
```

Author
======

Saif Ali - saif.ali@sudoconsultants.com

Hameedullah Khan - hameed@sudoconsultants.com

License
=======

[MIT](./LICENSE)
