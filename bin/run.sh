#!/bin/bash

# CHANGE IT !!
fqdn=gitlab.example.com

# https://gitlab.com/gitlab-org/omnibus-gitlab/-/raw/master/files/gitlab-config-template/gitlab.rb.template
read -r -d '' GITLAB_OMNIBUS_CONFIG << EOF
external_url "https://$fqdn"
gitlab_rails["initial_root_password"] = "training";
EOF

export GITLAB_OMNIBUS_CONFIG

docker run --rm -it -p 8000:80 -p 2200:22 \
  -e GITLAB_OMNIBUS_CONFIG \
  -v $(pwd)/.gitlab/config:/etc/gitlab \
  -v $(pwd)/.gitlab/logs:/var/log/gitlab \
  -v $(pwd)/.gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ee:latest