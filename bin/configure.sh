#!/bin/bash

user_name=student
user_password=training
group_name=foo
project_name=bar

# set -ex

if [[ -z "${GITLAB_URL}" ]] ; then
    echo "Gitlab URL is missing (GITLAB_URL)"
    exit 1
fi

if [[ -z "${GITLAB_API_TOKEN}" ]] ; then
    echo "Gitlab API token is missing (GITLAB_API_TOKEN)"
    exit 1
fi

user_json=$(curl -s -X POST \
  --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
  --header "Content-Type: application/json" \
  --data '{ "email": "student@home.net", "name": "'"${user_name^}"'", "username": "'"${user_name,,}"'", "password": "'"${user_password}"'", "skip_confirmation": true}' \
  "${GITLAB_URL}/api/v4/users/")

user_json=$(curl -s -X GET \
  --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
  "${GITLAB_URL}/api/v4/users" \
  | jq --arg user_name "${user_name,,}" --raw-output '.[] | select(.username == $user_name)')

user_id=$(echo "${user_json}" | jq --raw-output '.id')

curl -s -X POST \
  --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
  --header "Content-Type: application/json" \
  --data '{"name": "'"${group_name^}"'", "path": "'"${group_name,,}"'", "visibility": "public", "auto_devops_enabled": false}' \
  "${GITLAB_URL}/api/v4/groups/" 2>&1 >/dev/null

group_json=$(curl -s -X GET \
  --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
  "${GITLAB_URL}/api/v4/groups/${group_name}")

group_id=$(echo "${group_json}" | jq '.id')

curl -s -X POST \
  --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
  --data "user_id=${user_id}&access_level=30" \
  "${GITLAB_URL}/api/v4/groups/${group_id}/members" 2>&1 >/dev/null

for project_name in bar baz ; do
  curl -s -X POST \
    --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
    --header "Content-Type: application/json" \
    --data '{ "name": "'"${project_name^}"'", "path": "'"${project_name,,}"'", "namespace_id": "'"${group_id}"'", "visibility": "public", "import_url": "https://github.com/ericcitaire/ready2use-gitlab.git", "analytics_access_level": "disabled", "builds_access_level": "disabled", "container_registry_access_level": "disabled", "forking_access_level": "disabled", "issues_access_level": "disabled", "merge_requests_access_level": "disabled", "operations_access_level": "disabled", "pages_access_level": "disabled", "repository_access_level": "enabled", "requirements_access_level": "disabled", "security_and_compliance_access_level": "disabled", "snippets_access_level": "disabled", "wiki_access_level": "disabled"}' \
    "${GITLAB_URL}/api/v4/projects/" 2>&1 >/dev/null
done

# project_json=$(curl -s -X GET \
#   --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
#   "${GITLAB_URL}/api/v4/projects" \
#   | jq --arg project_name "${project_name,,}" --raw-output '.[] | select(.path == $project_name)')
# 
# project_id=$(echo "${project_json}" | jq '.id')
# 
# curl -s -X POST \
#   --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
#   --data "user_id=${user_id}&access_level=50" \
#   "${GITLAB_URL}/api/v4/projects/${project_id}/members" 2>&1 >/dev/null
