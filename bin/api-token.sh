#!/bin/bash

# set -ex

if [[ -z "${GITLAB_URL}" ]] ; then
    echo "Gitlab URL is missing (GITLAB_URL)"
    exit 1
fi

get_csrf_param() {
    read -r -d '' awk_script <<'EOF'
    BEGIN {
        param="?";
        token="?";
    }
    match($0, /<meta name="csrf-param" content="(.*)" \/>/, a) {
        param=a[1];
    } match($0, /<meta name="csrf-token" content="(.*)" \/>/, a) {
        token=a[1];
    }
    END {
        printf("%s=%s", param, token);
    }
EOF
    curl -s -b cookies.txt -c cookies.txt -sSL "$1" | gawk "${awk_script}"
}

gitlab_user=root
gitlab_password=training
rm -f cookies.txt
curl -s -c cookies.txt "${GITLAB_URL}" 2>&1 >/dev/null

csrf_param=$(get_csrf_param "${GITLAB_URL}/users/sign_in")

curl -s -b cookies.txt -c cookies.txt "${GITLAB_URL}/users/sign_in" \
	--data "user[login]=${gitlab_user}&user[password]=${gitlab_password}" \
	--data-urlencode "${csrf_param}" 2>&1 >/dev/null

csrf_param=$(get_csrf_param "${GITLAB_URL}/-/profile/personal_access_tokens")

expires_at=$(date -d "+48 hours" +"%Y-%m-%d")
api_token=$(curl -sL -b cookies.txt -c cookies.txt "${GITLAB_URL}/-/profile/personal_access_tokens" \
	--data-urlencode "${csrf_param}" \
	--data "personal_access_token[name]=foo&personal_access_token[expires_at]=${expires_at}&personal_access_token[scopes][]=api" \
  | jq --raw-output '.new_token')

echo "${api_token}"