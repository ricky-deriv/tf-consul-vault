#!/bin/bash

sudo hostnamectl set-hostname server01
echo "#hello" | sudo tee -a /etc/hosts
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install consul
consul --version

sudo mv ~/consul* ~/dc1* /etc/consul.d