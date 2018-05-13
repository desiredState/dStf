# dStf

An opinionated Terraform wrapper by desiredState.

## Installation

To install the `dstf` command-line tool simply paste the following command into a shell. If you get a `Permission denied` error, try `sudo -i` first.

```bash
curl -L https://raw.githubusercontent.com/desiredState/dStf/master/wrapper.sh > /usr/local/bin/dstf && chmod +x /usr/local/bin/dstf
```

## Prerequisites

dStf expects your Terraform repo to be formatted like so:

```sh
.
├── .gitignore               # Ensures you don't push secrets, etc, to the remote. See below for content.
├── dev-secrets.tfvars       # dev workspace specific variables. See below for content.
├── prod-secrets.tfvars      # prod workspace specific variables. See below for content.
└── terraform                # This directory contains all your Terraform configurations.
    ├── variables-common.tf  # This initialises the above tfvars. See below for content.
    └── main.tf              # A placeholder for your own Terraform configuration.
```

#### .gitignore
It is **important** to ensure you have the following entries in your repo's `.gitignore` file. Missing these could lead to secrets being pushed to the remote.

```sh
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

#### AWS credentials

Create a `Programmatic access` IAM user and access keys with `AdministratorAccess` role permissions for Terraform in AWS.

#### {dev,prod}-secrets.tfvars

To keep any secrets out of source control you'll need create a `dev-secrets.tfvars` and a `prod-secrets.tfvars` file in the root directory of your Terraform repo with the following content (adjusting as necessary for the given account).

```yaml
# KEEP THIS FILE SECRET!
aws_access_key = "CHANGE_ME"
aws_secret_key = "CHANGE_ME"
```

## Usage

The `dstf` command must be executed from the root of your Terraform repo.

Usage and available commands can be seen like so:

```sh
dstf help
```

For example, to run a `terraform plan` against the `dev` workspace you can simply:

```sh
dstf plan dev
```