#!/bin/bash
set -ex

PATH_TO_GCP_CRED_FILE=$(realpath $1)

cd terraform 
terraform init && terraform destroy -auto-approve -var="credential_file_path=$PATH_TO_GCP_CRED_FILE"