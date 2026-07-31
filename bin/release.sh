#!/bin/bash
set -e

# Generate comprehensive release notes from git history
# This captures ALL commits since last release, not just chart updates

CHANGELOG_FILE="CHANGELOG.md"
RELEASE_NOTES_FILE=".release-notes.md"
COMMON_HIERA_FILE="modules/enableit/common/data/common.yaml"
OPENVOX_ENVIRONMENT="common::system::openvox::environment"
RELEASE_COMMIT_MSG="chore(doc): Update changelog"
# Run this when the helm chart update PR is merged into master
NEW_TAG=$1

# Highest version tag. Not `git describe`, which only sees tags that are
# ancestors of HEAD and silently falls back to an older one when a release
# was tagged off-branch.
PREVIOUS_TAG=$(git tag --sort=-v:refname | head -n1)

if [ -z "$NEW_TAG" ]; then
  echo "$0 need new tag version, current tag is $PREVIOUS_TAG"
  exit
fi

# Check if current branch is master
CURRENT_BRANCH=$(git branch --show-current)

if [[ "${CURRENT_BRANCH}" != "master" ]]; then
    echo "Error: Not on master branch. Current branch: ${CURRENT_BRANCH}"
    exit 1
fi

if git rev-parse -q --verify "refs/tags/$NEW_TAG" >/dev/null; then
    echo "Error: tag $NEW_TAG already exists"
    exit 1
fi

# A tag that is not an ancestor of HEAD means the range below is derived from
# the merge-base instead of the tagged commit.
if [ -n "$PREVIOUS_TAG" ] && ! git merge-base --is-ancestor "$PREVIOUS_TAG" HEAD; then
    echo "Warning: $PREVIOUS_TAG is not an ancestor of HEAD, it was tagged off-branch"
fi

if [ -z "$PREVIOUS_TAG" ]; then
    echo "No previous tag found, using all commits"
    COMMIT_RANGE="HEAD"
else
    echo "Generating release notes since $PREVIOUS_TAG..$NEW_TAG"
    COMMIT_RANGE="$PREVIOUS_TAG..HEAD"
fi

# Initialize arrays for categorization
declare -a FEATURES
declare -a BUG_FIXES
declare -a CONFIG_CHANGES
declare -a OTHER_CHANGES

# Process commits
while IFS= read -r commit; do
    # Get commit message (first line only)
    message=$(git log --format=%s -n 1 "$commit")
    short_hash=$(git log --format=%h -n 1 "$commit")

    # Skip merge commits and the changelog commits this script creates
    if [[ $message =~ ^Merge ]] || [[ $message == "$RELEASE_COMMIT_MSG" ]]; then
      continue
    fi

      formatted_message="- $short_hash $message"

    # Categorize commits
    if [[ $message =~ ^feat ]]; then
        FEATURES+=("$formatted_message")
    elif [[ $message =~ ^fix ]]; then
        BUG_FIXES+=("$formatted_message")
    elif [[ $message =~ ^chore ]]; then
        CONFIG_CHANGES+=("$formatted_message")
    else
        OTHER_CHANGES+=("$formatted_message")
    fi
done < <(git rev-list "$COMMIT_RANGE")

cat $CHANGELOG_FILE | tail -n +5 > $CHANGELOG_FILE.tmp

# Generate release notes file
{
  printf '%s\n' "## LinuxAid Release Version ${NEW_TAG}"
  echo ""

   if [ ${#FEATURES[@]} -gt 0 ]; then
       echo "### Features"
       printf '%s\n' "${FEATURES[@]}"
       echo ""
   fi

   if [ ${#BUG_FIXES[@]} -gt 0 ]; then
       echo "### Bug Fixes"
       printf '%s\n' "${BUG_FIXES[@]}"
       echo ""
   fi

   if [ ${#CONFIG_CHANGES[@]} -gt 0 ]; then
       echo "### Configuration Changes"
       printf '%s\n' "${CONFIG_CHANGES[@]}"
       echo ""
   fi

   if [ ${#OTHER_CHANGES[@]} -gt 0 ]; then
       echo "### Other Changes"
       printf '%s\n' "${OTHER_CHANGES[@]}"
       echo ""
   fi

   # If no commits categorized, add a note
   total=$((${#FEATURES[@]} + ${#BUG_FIXES[@]} + ${#CONFIG_CHANGES[@]} + ${#OTHER_CHANGES[@]}))
   if [ $total -eq 0 ]; then
       echo "No changes in this release."
   fi
} > "$RELEASE_NOTES_FILE"

{
  printf '%s\n' "# Changelog"
  echo ""
  printf '%s\n' "All releases and the changes included in them (pulled from git commits added since last release) will be detailed in this file."
  echo ""
} > "$CHANGELOG_FILE"


# Prepend the new release note in the changelog.md file
cat "$RELEASE_NOTES_FILE" "$CHANGELOG_FILE.tmp" >> "$CHANGELOG_FILE"

echo "Release notes generated: $CHANGELOG_FILE"
rm -fr $CHANGELOG_FILE.tmp

# yq ends up removing the blank lines
#yq eval -i -P ".[\"common::openvox::environment\"] = \"$NEW_TAG\"" "$COMMON_HIERA_FILE"
# Match the current value rather than $PREVIOUS_TAG, then assert the end state.
# sed exits 0 when nothing matches, so set -e cannot catch a missed key.
sed -i "s/^$OPENVOX_ENVIRONMENT: \".*\"/$OPENVOX_ENVIRONMENT: \"$NEW_TAG\"/" "$COMMON_HIERA_FILE"
if ! grep -qx "$OPENVOX_ENVIRONMENT: \"$NEW_TAG\"" "$COMMON_HIERA_FILE"; then
    echo "Error: could not set $OPENVOX_ENVIRONMENT to \"$NEW_TAG\" in $COMMON_HIERA_FILE"
    echo "       Found: $(grep "^$OPENVOX_ENVIRONMENT:" "$COMMON_HIERA_FILE" || echo '<key absent>')"
    exit 1
fi
echo "Openvox environment is updated to $NEW_TAG"

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A "$CHANGELOG_FILE" "$RELEASE_NOTES_FILE" "$COMMON_HIERA_FILE"
  git commit -m "$RELEASE_COMMIT_MSG"
fi

git tag -a "$NEW_TAG" -m "Linuxaid Release $NEW_TAG"

# origin is GitHub and is the release target
echo "Pushing changelog changes to Github"
git push origin master

echo "Pushing tag to Github"
git push origin "$NEW_TAG"

# gitea is a mirror. It lags behind origin, so a rejected push here must not
# fail a release that is already published.
echo "Mirroring to Gitea"
git push gitea master || echo "WARNING: mirror branch push failed"
git push gitea "$NEW_TAG" || echo "WARNING: mirror tag push failed"
