#!/bin/bash

sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<html><h1>Response coming from server</h1></html>" | sudo tee /var/www/html/index.html
sudo systemctl restart httpd
