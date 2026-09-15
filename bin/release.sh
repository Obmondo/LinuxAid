#!/bin/bash
set -e

CHANGELOG_FILE="CHANGELOG.md"
RELEASE_NOTES_FILE=".release-notes.md"
COMMON_HIERA_FILE="modules/enableit/common/data/common.yaml"
OPENVOX_ENVIRONMENT="common::system::openvox::environment"
RELEASE_COMMIT_MSG="chore(doc): Update changelog"

NEW_TAG=""
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --dry-run|-n)
            DRY_RUN=true
            ;;
        *)
            if [ -z "$NEW_TAG" ]; then
                NEW_TAG="$arg"
            fi
            ;;
    esac
done

print_error() {
    local title="$1"
    local description="$2"
    local solution="$3"
    echo ""
    echo "┌────────────────────────────────────────────────────────────"
    echo "│ ❌ LinuxAid Release Error: $title"
    echo "├────────────────────────────────────────────────────────────"
    echo "│ $description"
    echo "│"
    echo "│ 💡 Solution:"
    echo "│    $solution"
    echo "└────────────────────────────────────────────────────────────"
    echo ""
    exit 1
}

PREVIOUS_TAG=$(git tag --sort=-v:refname | head -n1)

# 1. Validate tag argument provided
if [ -z "$NEW_TAG" ]; then
    print_error "Missing tag argument" \
                "No release tag was provided when running the script." \
                "Run the release script with a semantic version tag, e.g.: bin/release.sh v1.9.0 [--dry-run] (Current latest tag is ${PREVIOUS_TAG:-none})"
fi

# 2. Validate Semantic Versioning format with 'v' prefix
if [[ ! "$NEW_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
    print_error "Invalid tag format" \
                "Tag '$NEW_TAG' does not follow semantic versioning with a 'v' prefix (expected format: vMAJOR.MINOR.PATCH, e.g., v1.9.0)." \
                "Provide a valid semver tag starting with 'v', e.g., bin/release.sh v1.9.0"
fi

# 3. Check if current branch is master
CURRENT_BRANCH=$(git branch --show-current)
if [[ "${CURRENT_BRANCH}" != "master" ]]; then
    print_error "Not on master branch" \
                "You are currently on branch '$CURRENT_BRANCH', but releases can only be created from 'master'." \
                "Switch to the master branch using: git checkout master"
fi

# 4. Validate Remotes configuration (origin -> GitHub, gitea -> Gitea)
if ! git remote get-url origin >/dev/null 2>&1; then
    print_error "Missing 'origin' remote" \
                "The 'origin' remote is not configured in your git repository." \
                "Add the GitHub remote using: git remote add origin git@github.com:Obmondo/LinuxAid.git"
fi

if ! git remote get-url gitea >/dev/null 2>&1; then
    print_error "Missing 'gitea' remote" \
                "The 'gitea' remote mirror is not configured in your git repository." \
                "Add the Gitea remote using: git remote add gitea ssh://git@gitea.obmondo.com:2223/EnableIT/LinuxAid.git"
fi

origin_url=$(git remote get-url origin)
gitea_url=$(git remote get-url gitea)

if [[ ! "$origin_url" =~ github\.com ]]; then
    print_error "Incorrect 'origin' remote URL" \
                "origin remote does not point to GitHub ($origin_url)." \
                "Ensure origin points to GitHub: git remote set-url origin git@github.com:Obmondo/LinuxAid.git"
fi

if [[ ! "$gitea_url" =~ gitea\.obmondo\.com ]]; then
    print_error "Incorrect 'gitea' remote URL" \
                "gitea remote does not point to Gitea ($gitea_url)." \
                "Ensure gitea points to Gitea: git remote set-url gitea ssh://git@gitea.obmondo.com:2223/EnableIT/LinuxAid.git"
fi

# 5. Fetch both remotes to ensure up-to-date refs
echo "Fetching latest refs from origin and gitea..."
git fetch origin master >/dev/null 2>&1 || true
git fetch gitea master >/dev/null 2>&1 || true

# 6. Check master tip commit comparison across remotes (detecting divergence / lagging remotes)
local_commit=$(git rev-parse HEAD)
origin_commit=$(git rev-parse origin/master 2>/dev/null || echo "")
gitea_commit=$(git rev-parse gitea/master 2>/dev/null || echo "")

if [ "$local_commit" != "$origin_commit" ]; then
    print_error "Branch is not up-to-date with origin" \
                "Your local 'master' branch commit ($local_commit) is out of sync with 'origin/master' ($origin_commit)." \
                "Pull the latest changes before releasing: git pull origin master"
fi

if [ -n "$origin_commit" ] && [ -n "$gitea_commit" ] && [ "$origin_commit" != "$gitea_commit" ]; then
    echo ""
    echo "┌────────────────────────────────────────────────────────────"
    echo "│ ⚠️ Remote Sync Mismatch Detected"
    echo "├────────────────────────────────────────────────────────────"
    echo "│ • origin (GitHub) tip : $origin_commit"
    echo "│ • gitea  (Gitea)  tip : $gitea_commit"
    echo "│"
    echo "│ 💡 Explanation: Remotes have diverged or Gitea mirror is lagging."
    echo "└────────────────────────────────────────────────────────────"
    echo ""
    if [ "$DRY_RUN" = "true" ]; then
        echo "🔍 [DRY-RUN] Would prompt to synchronize gitea/master with origin/master."
    else
        read -p "Would you like to automatically synchronize gitea/master with origin/master before proceeding? (y/N): " sync_response
        case "$sync_response" in
            [yY][eE][sS]|[yY])
                echo "Pushing origin/master to gitea..."
                git push gitea origin/master:master
                ;;
            *)
                print_error "Remote sync aborted" \
                            "Remotes are out of sync and you chose not to synchronize." \
                            "Manually synchronize git remotes before running release."
                ;;
        esac
    fi
fi

# 7. Remote Tag Audit (Split-Brain / Partial Release Detection)
echo "Auditing remote tags for split-brain states..."
origin_has_tag=false
gitea_has_tag=false

if git ls-remote --tags origin | grep -q "refs/tags/$NEW_TAG\$"; then
    origin_has_tag=true
fi

if git ls-remote --tags gitea | grep -q "refs/tags/$NEW_TAG\$"; then
    gitea_has_tag=true
fi

if [ "$origin_has_tag" = "true" ] && [ "$gitea_has_tag" = "false" ]; then
    echo ""
    echo "┌────────────────────────────────────────────────────────────"
    echo "│ ⚠️ Split-Brain LinuxAid Release Detected"
    echo "├────────────────────────────────────────────────────────────"
    echo "│ • Tag $NEW_TAG already exists on GitHub (origin), but is missing on Gitea."
    echo "└────────────────────────────────────────────────────────────"
    echo ""
    if [ "$DRY_RUN" = "true" ]; then
        echo "🔍 [DRY-RUN] Would prompt to push missing tag $NEW_TAG to Gitea."
    else
        read -p "Would you like to push the missing tag $NEW_TAG to Gitea now? (y/N): " tag_sync_response
        case "$tag_sync_response" in
            [yY][eE][sS]|[yY])
                echo "Pushing tag $NEW_TAG to gitea..."
                git push gitea "refs/tags/$NEW_TAG:refs/tags/$NEW_TAG"
                echo "Sync completed successfully."
                exit 0
                ;;
            *)
                echo "Exiting without changes."
                exit 0
                ;;
        esac
    fi
elif [ "$origin_has_tag" = "false" ] && [ "$gitea_has_tag" = "true" ]; then
    echo ""
    echo "┌────────────────────────────────────────────────────────────"
    echo "│ ⚠️ Split-Brain LinuxAid Release Detected"
    echo "├────────────────────────────────────────────────────────────"
    echo "│ • Tag $NEW_TAG already exists on Gitea, but is missing on GitHub (origin)."
    echo "└────────────────────────────────────────────────────────────"
    echo ""
    if [ "$DRY_RUN" = "true" ]; then
        echo "🔍 [DRY-RUN] Would prompt to push missing tag $NEW_TAG to GitHub (origin)."
    else
        read -p "Would you like to push the missing tag $NEW_TAG to GitHub (origin) now? (y/N): " tag_sync_response
        case "$tag_sync_response" in
            [yY][eE][sS]|[yY])
                echo "Pushing tag $NEW_TAG to origin..."
                git push origin "refs/tags/$NEW_TAG:refs/tags/$NEW_TAG"
                echo "Sync completed successfully."
                exit 0
                ;;
            *)
                echo "Exiting without changes."
                exit 0
                ;;
        esac
    fi
fi

# 8. Check if local tag already exists
if git rev-parse -q --verify "refs/tags/$NEW_TAG" >/dev/null; then
    print_error "Tag already exists" \
                "Tag '$NEW_TAG' already exists in the repository." \
                "Choose a newer unique version tag."
fi

# 9. Check if new tag is greater than previous tag
if [ -n "$PREVIOUS_TAG" ]; then
    sorted=$(printf "%s\n%s\n" "${PREVIOUS_TAG#v}" "${NEW_TAG#v}" | sort -V)
    first_line=$(echo "$sorted" | head -n1)
    if [ "${NEW_TAG#v}" = "${PREVIOUS_TAG#v}" ]; then
        print_error "Duplicate version" \
                    "New tag '$NEW_TAG' is identical to the previous tag '$PREVIOUS_TAG'." \
                    "Provide a higher version number than the previous release."
    elif [ "$first_line" = "${NEW_TAG#v}" ]; then
        print_error "Version regression" \
                    "New tag '$NEW_TAG' is lower than or equal to the previous tag '$PREVIOUS_TAG'." \
                    "Ensure the new release version is greater than $PREVIOUS_TAG."
    fi
fi

# 10. Check write access / pushability using dry-run
echo "Verifying push permissions on remotes..."
if ! git push --dry-run origin master >/dev/null 2>&1; then
    print_error "Push access denied on 'origin'" \
                "You do not have write permissions or SSH authentication failed for GitHub (origin)." \
                "Check your SSH keys and GitHub write permissions for Obmondo/LinuxAid."
fi

if ! git push --dry-run gitea master >/dev/null 2>&1; then
    print_error "Push access denied on 'gitea'" \
                "You do not have write permissions or SSH authentication failed for Gitea mirror." \
                "Check your SSH keys and Gitea write permissions for EnableIT/LinuxAid."
fi

latest_commit_msg=$(git log --format="%h - %s" -n 1 HEAD)

# 11. Interactive Summary Dashboard & Confirmation Prompt
echo ""
echo "┌────────────────────────────────────────────────────────────"
echo "│ 🚀 LinuxAid Release Preview $( [ "$DRY_RUN" = "true" ] && echo "(DRY RUN MODE)" )"
echo "├────────────────────────────────────────────────────────────"
echo "│ • Current Branch : master (Up-to-date)"
echo "│ • Latest Commit  : $latest_commit_msg"
echo "│ • Previous Tag   : ${PREVIOUS_TAG:-None}"
echo "│ • New Tag        : $NEW_TAG"
echo "│ • Target Remotes :"
echo "│    - origin (GitHub) -> $origin_url"
echo "│    - gitea  (Gitea)  -> $gitea_url"
echo "└────────────────────────────────────────────────────────────"
echo ""

if [ "$DRY_RUN" = "true" ]; then
    echo "🔍 [DRY-RUN] Skipping interactive confirmation prompt."
else
    read -p "Do you want to proceed with creating and publishing release $NEW_TAG? (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY])
            echo "Proceeding with release..."
            ;;
        *)
            echo "Release cancelled by user."
            exit 0
            ;;
    esac
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

if [ "$DRY_RUN" = "true" ]; then
    echo ""
    echo "--- [DRY-RUN] Simulated Release Notes (${RELEASE_NOTES_FILE}) ---"
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
    echo "-------------------------------------------------------------"
    echo "🔍 [DRY-RUN] Would update $COMMON_HIERA_FILE with $OPENVOX_ENVIRONMENT: \"$NEW_TAG\""
    echo "🔍 [DRY-RUN] Would commit changes with message: \"$RELEASE_COMMIT_MSG\""
    echo "🔍 [DRY-RUN] Would create annotated git tag: \"$NEW_TAG\""
    echo "🔍 [DRY-RUN] Would push branch and tag to 'origin' (GitHub)"
    echo "🔍 [DRY-RUN] Would mirror push branch and tag to 'gitea' (Gitea)"
    echo ""
    echo "✨ Dry run completed successfully. No changes were made."
    exit 0
fi

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
