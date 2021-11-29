#!/usr/bin/env bash

SCRIPT=$1

if [[ -z $GITHUB_PAT ]]; then
    echo "GITHUB_PAT env var must be set. You can create a personal access token at https://github.com/settings/tokens"
    exit 1
fi

REPOS=$(curl https://api.github.com/orgs/NHSDigital/teams/api-gateway/repos -H "Authorization: Bearer $GITHUB_PAT" 2> /dev/null)
REPO_URLS=$(echo $REPOS | jq .[].git_url -r)
REPO_NAMES=$(echo $REPOS | jq .[].name -r)

echo "Found $(echo $REPO_URLS | wc -w) repositories in api-gateway"

if [[ -z $SCRIPT ]]; then
    echo "Ensuring .repo-cache exists"
    mkdir -p .repo-cache

    echo "Cloning repos..."
    for REPO_URL in $REPO_URLS; do
        echo -n "  Cloning $REPO_URL..."
        git -C .repo-cache clone $REPO_URL 2> /dev/null
        echo "done"
    done

    echo "Syncing repos..."
    for REPO_NAME in $REPO_NAMES; do
        echo -n "  Syncing $REPO_NAME..."
        git -C .repo-cache/$REPO_NAME stash > /dev/null 2> /dev/null
        git -C .repo-cache/$REPO_NAME checkout master > /dev/null 2> /dev/null

        # check out main if master is not present
        if [ $? -ne 0 ]; then
            git -C .repo-cache/$REPO_NAME checkout main > /dev/null 2> /dev/null
        fi

        git -C .repo-cache/$REPO_NAME pull > /dev/null 2> /dev/null
        echo "done"
    done
fi

CURDIR=$(pwd)

if [[ -n $SCRIPT ]]; then
    for REPO_NAME in $REPO_NAMES; do
        cd .repo-cache/$REPO_NAME 2> /dev/null

        # only run the sscript if the repo exists
        if [ $? -eq 0 ]; then
            cp $CURDIR/$SCRIPT ./$SCRIPT
            chmod +x ./$SCRIPT
            env GITHUB_PAT=$GITHUB_PAT REPO_NAME=$REPO_NAME ./$SCRIPT
            rm $SCRIPT
        fi

        cd $CURDIR
    done
fi
