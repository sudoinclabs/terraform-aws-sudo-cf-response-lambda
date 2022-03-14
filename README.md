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
  source = "github.com/sudoinclabs/terraform-aws-sudo-cf-response-lambda"
}
```

With customer lambda function (see below for further instructions.)

```hcl
module "cf_custom_lambda_sns" {
  source = "github.com/sudoinclabs/terraform-aws-sudo-cf-response-lambda"
  code   = "code"
}
```


Output
-------

 - `cf_backed_sns_arn` - ARN to be used in CloudFormation template as custom resource.

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