#!/bin/bash
dnf install -y nginx
systemctl enable --now nginx
echo "<h1>${project_name} - ${environment} - Web Tier - $(hostname -f)</h1>" > /usr/share/nginx/html/index.html