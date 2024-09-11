#!/bin/bash

# NOTE ipv4 is a subset of ipv6 so we're configuring ipv6 lists only.
# When a user visits from an ipv4 address, haproxy converts it to ipv6 equivalent for stick table entry.

if ! [[ "${AUTHENTICATED_REPO_URL}" ]]; then
    echo >&2 "Missing authenticated repo clone URL"
    exit 1
fi

CLONE_LOC="/tmp/iplistupdatebot"
TMP_LOC="/tmp/iplistdb"
DB_ZIP="${TMP_LOC}/ip2loc-lite.zip"
DEPLOY_TARGET_BRANCH="${DEPLOY_TARGET_BRANCH:-main}"

# Cleanup.
rm -rf "${TMP_LOC}" "${CLONE_LOC}"

# Configure git and clone repo.
git config --global user.email "iplistupdatebot@enableit.dk"
git config --global user.name "IP List Update Bot"

git clone "${AUTHENTICATED_REPO_URL}" "${CLONE_LOC}"
git -C "${CLONE_LOC}" checkout -b "update-iplists-$(date +%s)" --track "origin/${DEPLOY_TARGET_BRANCH}"

# Download and extract the latest db.
mkdir -p "${TMP_LOC}"
curl "https://download.ip2location.com/lite/IP2LOCATION-LITE-DB1.IPV6.CSV.ZIP" \
    -o "${DB_ZIP}"
unzip "${DB_ZIP}" -d "${TMP_LOC}"

# Generate ip lists from database for selected countries.
python3 "${CLONE_LOC}/bin/gen_cidr_list_ipv6.py" "${TMP_LOC}/IP2LOCATION-LITE-DB1.IPV6.CSV" \
    "DK" >"${CLONE_LOC}/envs/production/modules/enableit/eit_haproxy/files/iplists/DK.txt"

# Commit and make a pull request if database was updated.
git -C "${CLONE_LOC}" add -f envs/production/modules/enableit/eit_haproxy/files/iplists/*

CHANGES=$(git -C "${CLONE_LOC}" status --porcelain | wc -l)
echo "${CHANGES}"

if ((CHANGES > 0)); then
    COMMIT_TITLE='Update IP Lists'

    git -C "${CLONE_LOC}" status
    git -C "${CLONE_LOC}" commit -m "${COMMIT_TITLE}"

    # shellcheck disable=SC2094
    OUTPUT=$(git 2>&1 -C "${CLONE_LOC}" push \
        --force-with-lease \
        -o merge_request.create \
        -o merge_request.target="${DEPLOY_TARGET_BRANCH}" \
        -o merge_request.title="${COMMIT_TITLE}" \
        -o merge_request.merge_when_pipeline_succeeds \
        -o merge_request.remove_source_branch \
        -o merge_request.description="Auto-generated pull request." \
        "${AUTHENTICATED_REPO_URL}" HEAD)
    echo "${OUTPUT}"

    if grep -q WARNINGS <<<"${OUTPUT}"; then
        exit 1
    fi
fi
