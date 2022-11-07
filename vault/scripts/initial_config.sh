#!/bin/bash

sudo yum install -y yum-utils
sudo yum install -y jq
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install vault
sudo chown root:root /opt/vault/tls/tls.crt /opt/vault/tls/tls.key
sudo chown root:vault /opt/vault/tls/tls.key
sudo chmod 0644 /opt/vault/tls/tls.crt
sudo chmod 0640 /opt/vault/tls/tls.key
export PRIVATE_IP=$(hostname -I | awk '{print $1}')

sudo tee -a /etc/vault.d/vault.hcl > /dev/null <<EOF 
cluster_addr  = "http://$PRIVATE_IP:8201"
api_addr      = "https://$PRIVATE_IP:8200"

# HTTP listener
listener "tcp" {
  address = "0.0.0.0:8202"
  tls_disable = 1
}
EOF

sudo systemctl enable vault.service
sudo systemctl start vault.service

export VAULT_ADDR=http://$PRIVATE_IP:8202
export VAULT_SECRETS_PATH="/home/ec2-user/vault-init-secrets.json"
vault operator init -format json > $VAULT_SECRETS_PATH
vault operator unseal $(cat $VAULT_SECRETS_PATH | jq -r .unseal_keys_b64[0])
vault operator unseal $(cat $VAULT_SECRETS_PATH | jq -r .unseal_keys_b64[1])
vault operator unseal $(cat $VAULT_SECRETS_PATH | jq -r .unseal_keys_b64[2])
vault login $(cat $VAULT_SECRETS_PATH | jq -r .root_token)

tee /home/ec2-user/read-users-policy.hcl > /dev/null <<EOF
path "users/*" {
  capabilities = ["read", "list"]
}
EOF

vault policy write users-read /home/ec2-user/read-users-policy.hcl
vault token create -policy=users-read -format json > /home/ec2-user/read-users-policy-output.json