#!/bin/bash

# CHANGE IT !!
# fqdn='??'
fqdn="8000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"

# https://gitlab.com/gitlab-org/omnibus-gitlab/-/raw/master/files/gitlab-config-template/gitlab.rb.template
read -r -d '' GITLAB_OMNIBUS_CONFIG << EOF
gitlab_rails["initial_root_password"] = "training";
EOF

export GITLAB_OMNIBUS_CONFIG

docker run --rm -it --name gitlab -p 8000:80 -p 8443:443 -p 2200:22 \
  -e GITLAB_OMNIBUS_CONFIG \
  -v $(pwd)/.gitlab/config:/etc/gitlab \
  -v $(pwd)/.gitlab/logs:/var/log/gitlab \
  -v $(pwd)/.gitlab/data:/var/opt/gitlab \
  --hostname "${fqdn}" \
  gitlab/gitlab-ee:latest