### Generic VPC Terraform module

#### Example usage

```
module "main" {
  source              = "git@github.com:stain89/terraform-module-vpc.git"
  aws_region          = "eu-central-1"
  availability_zones  = ["eu-central-1a", "eu-central-1b"]
  vpc_cidr            = "10.10.0.0/24"
  public_subnet_cidr  = ["10.10.0.0/26", "10.10.0.64/26"]
  private_subnet_cidr = ["10.10.0.128/26", "10.10.0.192/26"]
  name                = "test"
  environment         = "test"
}
```
