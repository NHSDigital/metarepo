#!/usr/bin/env bash

declare -A PROJECTS

NHSD_JIRA_URL="https://nhsd-jira.digital.nhs.uk/browse/<num>"
PROJECTS=( \
    ["APM"]="$NHSD_JIRA_URL" \
    ["AMB"]="$NHSD_JIRA_URL" \
    ["APMSPII"]="$NHSD_JIRA_URL" \
)


for PROJECT in "${!PROJECTS[@]}"; do
    curl "https://api.github.com/repos/NHSDigital/$REPO_NAME/autolinks" \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer $GITHUB_PAT" \
        -d "{\"key_prefix\": \"$PROJECT-\",\"url_template\":\"${PROJECTS[$PROJECT]}\"}"
done
