#! /bin/sh

ansible-playbook ../provisioning/deploys/staging.yml -i provisioning/hosts -c paramiko --private-key=../provisioning/keys/id_rsa_staging
