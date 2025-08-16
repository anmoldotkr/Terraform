#!/bin/bash

sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Hello, Terraform EC2..!" > /var/www/html/index.html
