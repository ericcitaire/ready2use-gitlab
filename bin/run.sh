#!/bin/bash

read -r -d '' GITLAB_OMNIBUS_CONFIG <<'EOF'
gitlab_rails['initial_root_password'] = "initialpassword";
EOF

export GITLAB_OMNIBUS_CONFIG

docker run --rm -it -p 8000:80 -p 2200:22 \
  -e GITLAB_OMNIBUS_CONFIG \
  -v $(pwd)/.gitlab/config:/etc/gitlab \
  -v $(pwd)/.gitlab/logs:/var/log/gitlab \
  -v $(pwd)/.gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ee:latest