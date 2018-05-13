# dStf

An opinionated Terraform wrapper by desiredState.

## Installation

Simply paste the following command into a shell:

```bash
curl -L https://raw.githubusercontent.com/desiredState/dStf/master/wrapper.sh > /usr/local/bin/dstf && chmod +x /usr/local/bin/dstf
```

If you get a `Permission denied` error, try `sudo -i` then the above command again.

## Prerequisites

* Create a Terraform repo containing a `terraform` directory.

* IMPORTANT! Ensure you have the following entries in your Terraform repo's `.gitignore` file.

```
# Sensitive files.
secrets.tfvars
*-secrets.tfvars

# Terraform compiled files.
*.tfstate
*.tfstate.backup
*.tfplan
terraform.tfstate.d/

# Terraform modules directory.
.terraform/

# dStf files.
.dstf-init.done
```

* Create a `Programmatic access` IAM user and access keys with `AdministratorAccess` role permissions for Terraform in AWS.

* To keep any secrets out of source control you'll need create a `dev-secrets.tfvars` and a `prod-secrets.tfvars` file in the root directory of your Terraform repo with the following content (adjusting as necessary for the given account).

```yaml
# KEEP THIS FILE SECRET!

aws_access_key = "CHANGE_ME"
aws_secret_key = "CHANGE_ME"
```

## Usage

Usage can be seen like so:

```sh
dstf help
```

For example, to run a `terraform plan` against the `dev` workspace you can simply:

```sh
dstf plan dev
```