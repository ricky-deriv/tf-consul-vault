#!/bin/bash

sudo yum install -y yum-utils
sudo yum install -y jq
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install vault

curl -O https://releases.hashicorp.com/consul-template/0.29.5/consul-template_0.29.5_linux_amd64.zip
unzip consul-template_0.29.5_linux_amd64.zip
sudo mv consul-template /usr/local/bin
consul-template --version

# template file
tee /home/ec2-user/users.tpl > /dev/null <<EOF
{{ range secrets "users" }}{{ \$user := . }}{{ with secret (print "users/" \$user) }}{{ \$user }},{{ .Data.qa_key }}{{end}}{{end}}
EOF

# consul-template config file
tee /home/ec2-user/ct-config.hcl > /dev/null <<EOF
vault {
	address = "http://<PUBLIC_IP>:8202"
	token = "<TOKEN>"
	renew_token = false
}

template {
	source = "./users.tpl"
	destination = "./users.csv"
	command = "bash ~/update-users.sh"
}
EOF

# consul-template bash script
tee /home/ec2-user/update-users.sh > /dev/null <<EOF
#!/bin/bash

while IFS=, read -r username public_key
do
	if id \$username &>/dev/null; then
		echo 'user found'
	else
		echo 'user not found'
		sudo useradd -m \$username
	fi

	if [[ -z "$(grep -w \$username ~/.ssh/authorized_keys)" ]]; then
		echo "no key"
		printf "# \$username \n\$public_key\n" >> ~/.ssh/authorized_keys
	else
		echo "key"
	fi
done < users.csv
EOF

