#!/bin/bash

# This Bash script is designed to perform a series of validations on Terraform code

# Accept Command Line Arguments
SKIPVALIDATIONFAILURE=$1 # Flag to determine whether to skip validation errors on failure or not.
tfValidate=$2 # Flag to determine whether to run terraform validate or not.
tfFormat=$3 # Flag to determine whether to run terraform format or not.
tfCheckov=$4 # Flag to determine whether to run checkov or not.
tfTfsec=$5 # Flag to determine whether to run tfsec or not.
# -----------------------------

# Print an overview of the validation configuration.
echo "### VALIDATION Overview ###"
echo "-------------------------"
echo "Skip Validation Errors on Failure : ${SKIPVALIDATIONFAILURE}"
echo "Terraform Validate : ${tfValidate}"
echo "Terraform Format   : ${tfFormat}"
echo "Terraform checkov  : ${tfCheckov}"
echo "Terraform tfsec    : ${tfTfsec}"
echo "------------------------"

# Initialise the Terraform working directory
terraform init

# Based on the input flags, execute the corresponding validation tasks

# Check whether the Terraform code is syntactically valid and internally consistent, regardless of any provided variables or existing state.
if (( ${tfValidate} == "Y"))
then
    echo "## VALIDATION : Validating Terraform code ..."
    terraform validate #
fi
tfValidateOutput=$?

# Check whether the Terraform code is formatted correctly.
if (( ${tfFormat} == "Y"))
then
    echo "## VALIDATION : Formatting Terraform code ..."
    terraform fmt -recursive
fi
tfFormatOutput=$?

# Checkov is a static code analysis tool for IaC. It scans infrastructure provisioned using Terraform and detects security and compliance misconfigurations.
if (( ${tfCheckov} == "Y"))
then
    echo "## VALIDATION : Running checkov ..."
    #checkov -s -d .
    checkov -o junitxml --framework terraform -d ./ >checkov.xml
fi
tfCheckovOutput=$?

# Tfsec is a static analysis tool for Terraform code. It is designed to spot potential security issues that can occur in Terraform templates.
if (( ${tfTfsec} == "Y"))
then
    echo "## VALIDATION : Running tfsec ..."
    #tfsec .
    tfsec ./ --format junit --out tfsec-junit.xml
fi
tfTfsecOutput=$?

# Print a summary of the validation results.
echo "## VALIDATION Summary ##"
echo "------------------------"
echo "Terraform Validate : ${tfValidateOutput}"
echo "Terraform Format   : ${tfFormatOutput}"
echo "Terraform checkov  : ${tfCheckovOutput}"
echo "Terraform tfsec    : ${tfTfsecOutput}"
echo "------------------------"

# Based on the SKIPVALIDATIONFAILURE flag and the results of the validation tasks, it decides whether to continue or halt the process:
if (( ${SKIPVALIDATIONFAILURE} == "Y" ))
then
  # if SKIPVALIDATIONFAILURE is set as Y, then validation failures are skipped during execution
  echo "## VALIDATION : Skipping validation failure checks..."
elif (( $tfValidateOutput == 0 && $tfFormatOutput == 0 && $tfCheckovOutput == 0  && $tfTfsecOutput == 0 ))
then
  echo "## VALIDATION : Checks Passed!!!"
else
  # When validation checks fails, build process is halted.
  echo "## ERROR : Validation Failed"
  exit 1;
fi