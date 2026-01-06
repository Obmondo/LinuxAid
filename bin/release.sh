#!/bin/bash
set -e

# Generate comprehensive release notes from git history
# This captures ALL commits since last release, not just chart updates

CHANGELOG_FILE="CHANGELOG.md"
RELEASE_NOTES_FILE=".release-notes.md"
COMMON_HIERA_FILE="modules/enableit/common/data/common.yaml"
OPENVOX_ENVIRONMENT="common::openvox::environment"
# Run this when the helm chart update PR is merged into master
NEW_TAG=$1

# Get the previous tag
PREVIOUS_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$NEW_TAG" ]; then
  echo "$0 need new tag version, current tag is $PREVIOUS_TAG"
  exit
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

    # Skip merge commits
    if [[ $message =~ ^Merge ]]; then
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
sed -i "s/$OPENVOX_ENVIRONMENT: \"$PREVIOUS_TAG\"/$OPENVOX_ENVIRONMENT: \"$NEW_TAG\"/g" "$COMMON_HIERA_FILE"
echo "Openvox environment is updated to $NEW_TAG"

exit
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A "$CHANGELOG_FILE" "$RELEASE_NOTES_FILE" "$COMMON_HIERA_FILE"
  git commit -m "chore(doc): Update changelog"
fi

git tag -a "$NEW_TAG" -m "Linuxaid Release $NEW_TAG"

echo "Pushing changelog changes to Gitea"
git push origin master

echo "Pushing tag to Gitea"
git push origin "$NEW_TAG"

echo "Pushing changelog changes to Github"
git push github master

echo "Pushing tag to Github"
git push github "$NEW_TAG"
