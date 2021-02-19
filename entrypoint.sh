#!/bin/sh -l

GITHUB_TOKEN=$1
BRANCH_NAME=$2

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "error: no GITHUB_TOKEN supplied"
    exit 1
fi

if [ -z "${BRANCH_NAME}" ]; then
   export BRANCH_NAME=master
fi

touch model-access-permissions.configmap.yml
kubectl create configmap model-access-permissions --from-file ./configs/permissions --dry-run=client --validate=false -o yaml > model-access-permissions.configmap.yml
echo '  annotations:
    qontract.recycle: "true"' >> model-access-permissions.configmap.yml


remote_repo="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git config http.sslVerify false
git config user.name "[GitHub] - Automated Action"
git config user.email "actions@github.com"

git checkout ${BRANCH_NAME}
git add .
timestamp=$(date -u)
git commit -m "[GitHub] - Automated config conversion: ${timestamp} ${GITHUB_SHA}" || exit 0
git pull --rebase publisher ${BRANCH_NAME}
git push origin ${BRANCH_NAME}