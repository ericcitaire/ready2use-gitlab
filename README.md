# Ready to use GitLab

## Configure

```
export GITLAB_URL=http://gitlab.example.com
export GITLAB_API_TOKEN=$(./bin/api-token.sh)

./bin/configure.sh
```

### Gitpod

```
export GITLAB_URL=https://8000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}
export GITLAB_API_TOKEN=$(./bin/api-token.sh)

./bin/configure.sh
```
