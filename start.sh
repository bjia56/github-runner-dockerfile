#!/bin/bash

REPOSITORY=$REPO
ACCESS_TOKEN=$TOKEN

echo "REPO ${REPOSITORY}"

REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

unset REPO
unset TOKEN
unset ACCESS_TOKEN

cd /home/docker/actions-runner

./config.sh --url https://github.com/${REPOSITORY} --token ${REG_TOKEN} --ephemeral

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap 'cleanup; exit 0' EXIT
trap 'cleanup; exit 1' ERR

./run.sh & wait $!