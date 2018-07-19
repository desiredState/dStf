#!/usr/bin/env bash

TERRAFORM_BIN="terraform"
TERRAFORM_DATA="terraform/"
PLAN_FILE="dstf.tfplan"
LOCK_FILE=".dstf-init.done"
WORKSPACES=( 'dev' 'test' 'prod' )

# Internal dStf functions.

function print_usage {
    cat <<EOF
usage: dStf [-h] {plan,apply,destroy} $(printf "%s," "{${WORKSPACES[@]}}" | cut -d "," -f 1-${#WORKSPACES[@]}) ...

An opinionated Terraform wrapper by desiredState.

positional arguments:
  {plan,apply,wipe}
    plan                generate an execution plan
    apply               apply the latest execution plan
    destroy             destroy dStf-managed infrastructure

  $(
    printf "%s," "{${WORKSPACES[@]}}" | cut -d "," -f 1-${#WORKSPACES[@]}
    for ws in "${WORKSPACES[@]}"; do
        printf '    %-19s %s\n' "${ws}" "run the action against the ${ws} workspace"
    done
  )

optional arguments:
  -h, --help            show this help message
EOF
}

function dlog {
    none=$(tput sgr 0) # None.
    
    case $1 in
        white)
            colour=$(tput setaf 7)
        ;;
        cyan|info)
            colour=$(tput setaf 6)
        ;;
        green|success)
            colour=$(tput setaf 2)
        ;;
        red|error)
            colour=$(tput setaf 1)
        ;;
        bold)
            colour=$(tput bold)
        ;;
        *)
            colour=$(tput setaf 6)
    esac
    
    echo -e "$(tput bold)$(tput setaf 6)dStf >${none} ${colour}${2}${none}"
}

# Check dStf dependencies are satisfied.
function check_deps {
    DEPS=( 'tput' 'terraform' )
    
    for i in "${DEPS[@]}"; do
        if ! hash "${i}" 2>/dev/null; then
            dlog error "\"${i}\" is required to use dStf. Please install it and try again."
            exit 1
        fi
    done
}

# Runs once the first time dStf is executed.
function dstf_init {
    dlog info "It looks like you've never run dStf here before, let's set you up..."
    
    if [ ! -d "terraform" ]; then
        dlog error "Failed to find a \"${TERRAFORM_DATA}\" directory. See the README for instructions."
        exit 1
    fi
    
    for ws in "${WORKSPACES[@]}"; do
        dlog info "Creating the ${ws} workspace..."
        $TERRAFORM_BIN workspace new $ws $TERRAFORM_DATA
        if [[ $? -ne 0 ]]; then
            dlog error "Failed to create the ${ws} workspace."
            exit 1
        fi
        
        dlog info "Initialising the ${ws} workspace..."
        $TERRAFORM_BIN init $TERRAFORM_DATA
        if [[ $? -ne 0 ]]; then
            dlog error "Failed to initialise the ${ws} workspace."
            exit 1
        fi
    done
    
    touch $LOCK_FILE
    if [[ $? -ne 0 ]]; then
        dlog error "Failed to create dStf lock file."
        exit 1
    fi
}

# Runs every time dStf is executed.
function dstf_call {
    if [ ! -f "${1}-secrets.tfvars" ]; then
        dlog error "Failed to find your ${1}-secrets.tfvars file. See the README for instructions."
        exit 1
    fi
    
    dlog info "Updating Terraform modules..."
    $TERRAFORM_BIN get $TERRAFORM_DATA
    if [[ $? -ne 0 ]]; then
        dlog error "Failed to update Terraform modules."
        exit 1
    fi
    
    dlog success "Configured Terraform with:"
    dlog success "  - Workspace: ${1}"
    dlog success "  - Variables: ${1}-secrets.tfvars"
    
    tf_format
}

# Ensure a valid workspace name argument was provided.
function verify_workspace {
    found=false
    for ws in "${WORKSPACES[@]}"; do
        if [ "$1" == "$ws" ]; then
            found=true
        fi
    done
    
    if [ "$found" != "true" ]; then
        print_usage
        exit 1
    fi
}

# Select the given Terraform workspace.
function select_workspace {
    verify_workspace $1
    
    dlog info "Selecting the ${1} workspace..."
    $TERRAFORM_BIN workspace select $1
    if [[ $? -ne 0 ]]; then
        dlog error "Failed to select the ${1} workspace."
        exit 1
    fi
}

# Terraform invocation functions.

# Ensure all Terraform configuration is in canonical format.
function tf_format {
    dlog info "Ensuring configuration is properly formatted..."
    
    $TERRAFORM_BIN fmt \
    -diff=true \
    -write=true \
    $TERRAFORM_DATA
}

# Run an oppinionated Terraform Plan against the given workspace.
function tf_plan {
    dlog info "Running PLAN against the ${1} workspace..."
    
    $TERRAFORM_BIN plan \
    -out="${PLAN_FILE}" \
    -var-file="${1}-secrets.tfvars" \
    $TERRAFORM_DATA
    
    dlog success "Plan compiled. Run \"dstf apply ${1}\" to apply it."
}

# Run an oppinionated Terraform Apply against the given workspace.
function tf_apply {
    if [ ! -f "${PLAN_FILE}" ]; then
        dlog error "Failed to find the plan file. Please run \"dstf plan ${1}\" first."
        exit 1
    fi
    
    dlog info "Running APPLY against the ${1} workspace..."
    
    $TERRAFORM_BIN apply \
    "${PLAN_FILE}"
}

# Run an oppinionated Terraform Destroy against the given workspace.
function tf_destroy {
    dlog info "Running DESTROY against the ${1} workspace..."
    
    $TERRAFORM_BIN destroy \
    -var-file="${1}-secrets.tfvars" \
    $TERRAFORM_DATA
}

# Reverse everything the dstf_init function did.
function tf_wipe {
    $TERRAFORM_BIN workspace select default
    
    for ws in "${WORKSPACES[@]}"; do
        dlog info "Removing the ${ws} workspace..."
        $TERRAFORM_BIN workspace delete -force $ws
    done
    
    if [ -f $PLAN_FILE ]; then
        dlog info "Removing dStf plan file..."
        rm $PLAN_FILE
    fi
    
    dlog info "Removing dStf lock file..."
    rm $LOCK_FILE
    
    dlog success "Finished."
}

# Execution entrypoint.

cat <<EOF

                      $(tput setaf 7)$(tput bold)desired$(tput sgr 0)$(tput setaf 2)$(tput bold)State$(tput sgr 0)$(tput setaf 7)$(tput bold):$(tput sgr 0)
                          $(tput setaf 7)the rancher people$(tput sgr 0)

EOF

check_deps

if [ "$1" == "wipe" ]; then
    tf_wipe
    exit 0
fi

if [ ! -f $LOCK_FILE ]; then
    dstf_init
fi

select_workspace $2
dstf_call $2

case $1 in
    plan)
        tf_plan $2
    ;;
    apply)
        tf_apply $2
    ;;
    destroy)
        tf_destroy $2
    ;;
    *)
        print_usage
        exit 1
esac

dlog success "Finished."
