# dStf

An opinionated Terraform wrapper by desiredState.

## Installation

Simply paste the following command into a shell:

```bash
curl -L https://raw.githubusercontent.com/desiredstate/dstf/master/wrapper.sh > /usr/local/bin/dstf && chmod +x /usr/local/bin/dstf && dstf
```

If you get a `Permission denied` error, try `sudo -i` then the above command again.

## Prerequisites

* Install Docker on your local machine.

* Create a `Programmatic access` IAM user and access keys with `AdministratorAccess` role permissions for Terraform in AWS.

* To keep any secrets out of source control you'll need create a `dev-secrets.tfvars` and a `prod-secrets.tfvars` file in the root directory of this repository with the following content (adjusting as necessary for the given account). These are already added to the `.gitignore` file, however, you must still take care to KEEP THEM SECRET.

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