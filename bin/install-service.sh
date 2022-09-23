#!/bin/bash

# CHANGE IT !!
fqdn=gitlab.example.com

mkdir -p /etc/gitlab /var/log/gitlab /var/opt/gitlab

cat << EOF > /etc/gitlab.environment
GITLAB_OMNIBUS_CONFIG='
external_url "https://$fqdn"
gitlab_rails["initial_root_password"] = "training";
'
EOF

cat << EOF > /lib/systemd/system/gitlab.service
[Unit]
Description=Gitlab
BindsTo=docker.service
After=docker.service

[Service]
Type=exec
EnvironmentFile=/etc/gitlab.environment
ExecStart=/usr/bin/docker run --rm -i --name gitlab \
  --hostname $fqdn \
  -p 80:80 -p 443:443 -p 2200:22 \
  -e GITLAB_OMNIBUS_CONFIG \
  -v /etc/gitlab:/etc/gitlab \
  -v /var/log/gitlab:/var/log/gitlab \
  -v /var/opt/gitlab:/var/opt/gitlab \
  gitlab/gitlab-ee:latest
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl enable --now gitlab