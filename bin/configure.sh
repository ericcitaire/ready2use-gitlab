#!/bin/bash

# set -ex

if [[ -z "${GITLAB_URL}" ]] ; then
    echo "Gitlab URL is missing (GITLAB_URL)"
    exit 1
fi

if [[ -z "${GITLAB_API_TOKEN}" ]] ; then
    echo "Gitlab API token is missing (GITLAB_API_TOKEN)"
    exit 1
fi

http_get() {
  path="$1"

  curl -fs -X GET \
    --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
    --header "Content-Type: application/json" \
    "${GITLAB_URL}${path}"
}

http_post() {
  path="$1"
  data="$2"

  curl -fs -X POST \
    --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
    --header "Content-Type: application/json" \
    --data "${data}" \
    "${GITLAB_URL}${path}"
}

create_user() {
  user_email="$1"
  user_name="$2"
  user_password="$3"

  http_post \
      '/api/v4/users/' \
      '{ "email": "'"${user_email}"'", "name": "'"${user_name^}"'", "username": "'"${user_email/@*/}"'", "password": "'"${user_password}"'", "skip_confirmation": true}' \
       2>&1 >/dev/null
  http_get '/api/v4/users' | jq --arg user_email "${user_email}" --raw-output '.[] | select(.email == $user_email)'
}

greate_group() {
  group_name="$1"

  http_post \
      '/api/v4/groups/' \
      '{"name": "'"${group_name^}"'", "path": "'"${group_name,,}"'", "visibility": "public", "auto_devops_enabled": false}' \
       2>&1 >/dev/null
  http_get "/api/v4/groups/${group_name}"
}

add_group_member() {
  group_id="$1"
  user_id="$2"

  http_post \
      "/api/v4/groups/${group_id}/members" \
      "user_id=${user_id}&access_level=30" \
      2>&1 >/dev/null
}

import_project() {
  namespace_id="$1"
  project_name="$2"
  project_url="$3"

  http_post \
      '/api/v4/projects/' \
      '{ "name": "'"${project_name^}"'", "path": "'"${project_name,,}"'", "namespace_id": "'"${namespace_id}"'", "visibility": "public", "import_url": "'"${project_url}"'", "analytics_access_level": "disabled", "builds_access_level": "disabled", "container_registry_access_level": "disabled", "forking_access_level": "disabled", "issues_access_level": "disabled", "merge_requests_access_level": "disabled", "operations_access_level": "disabled", "pages_access_level": "disabled", "repository_access_level": "enabled", "requirements_access_level": "disabled", "security_and_compliance_access_level": "disabled", "snippets_access_level": "disabled", "wiki_access_level": "disabled"}' \
      2>&1 >/dev/null
}

user_names=(student1 student2)
user_emails=(student1@home.net student2@home.net)

for (( i=0; i<${#user_names[@]} ; i+=1 )) ; do
  echo -n "Creating user ${user_names[i]}..."
  user_info=$(create_user "${user_emails[i]}" "${user_names[i]}" "training")
  namespace_id=$(echo "${user_info}" | jq --raw-output '.namespace_id')
  import_project "${namespace_id}" "Maven" https://github.com/ericcitaire/example-maven-project.git
  import_project "${namespace_id}" "Node" https://github.com/ericcitaire/example-node-project.git
  echo " OK"
done
