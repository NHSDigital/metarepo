#!/usr/bin/env bash

declare -A PROJECTS

NHSD_JIRA_URL="https://nhsd-jira.digital.nhs.uk/browse"
PROJECTS=( \
    ["APM"]="$NHSD_JIRA_URL/APM-<num>" \
    ["AMB"]="$NHSD_JIRA_URL/AMB-<num>" \
    ["APMSPII"]="$NHSD_JIRA_URL/APMSPII-<num>" \
)

AUTOLINKS=$(curl "https://api.github.com/repos/NHSDigital/$REPO_NAME/autolinks" \
                 -H "Authorization: Bearer $GITHUB_PAT")
AUTOLINKS=$(echo $AUTOLINKS | jq -r '.[] | (.id|tostring) + " " + .key_prefix')

for PROJECT in "${!PROJECTS[@]}"; do
    ID=$(echo "$AUTOLINKS" | grep $PROJECT- | cut -d' ' -f1)
    if [[ -n $ID ]]; then
        echo "https://api.github.com/repos/NHSDigital/$REPO_NAME/autolinks/$ID"
        curl "https://api.github.com/repos/NHSDigital/$REPO_NAME/autolinks/$ID" \
            -X DELETE \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: Bearer $GITHUB_PAT"
    fi

    curl "https://api.github.com/repos/NHSDigital/$REPO_NAME/autolinks" \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer $GITHUB_PAT" \
        -d "{\"key_prefix\": \"$PROJECT-\",\"url_template\":\"${PROJECTS[$PROJECT]}\"}"
done
