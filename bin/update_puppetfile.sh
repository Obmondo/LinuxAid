#!/bin/bash

# Puppetfile Auto-Update Script
# This script automatically updates module refs to the latest tags

PUPPETFILE="${1:-.}/Puppetfile"
BACKUP_FILE="Puppetfile.backup.$(date +%Y%m%d_%H%M%S)"

if [ ! -f "$PUPPETFILE" ]; then
    echo "Error: Puppetfile not found at $PUPPETFILE"
    exit 1
fi

# Create backup
cp "$PUPPETFILE" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"
echo ""

# Create temp file
TEMP_FILE=$(mktemp)
cat "$PUPPETFILE" > "$TEMP_FILE"

# Extract git URLs and current refs
declare -A git_repos
declare -A current_refs

# Parse the Puppetfile to find git modules and their refs
while IFS= read -r line; do
    if [[ $line =~ ^mod\ \'([^\']+)\' ]]; then
        current_mod="${BASH_REMATCH[1]}"
    fi

    if [[ $line =~ :git\ \=\>\ [\'\"](.*?)[\'\"] ]]; then
        git_url="${BASH_REMATCH[1]}"
        git_repos["$current_mod"]="$git_url"
    fi

    if [[ $line =~ :ref\ \=\>\ [\'\"](.*?)[\'\"] ]]; then
        current_ref="${BASH_REMATCH[1]}"
        current_refs["$current_mod"]="$current_ref"
    fi
done < "$PUPPETFILE"

echo "Found ${#git_repos[@]} modules with git repositories"
echo ""

# Check each repository for updates
for mod in "${!git_repos[@]}"; do
    git_url="${git_repos[$mod]}"
    old_ref="${current_refs[$mod]}"

    # Clean up git URL
    git_url_clean=${git_url%.git}

    echo "Checking: $mod"
    echo "  Current ref: $old_ref"
    echo "  Git URL: $git_url_clean"

    # Get latest tag (semantic versioning, pre-release versions, or commit hashes)
    latest_tag=$(git ls-remote --tags "$git_url_clean" 2>/dev/null | \
                 grep -oP 'refs/tags/\K[^{}^]+' | \
                 sort -V | tail -1)

    if [ -n "$latest_tag" ]; then
        echo "  Latest tag: $latest_tag"

        if [ "$old_ref" != "$latest_tag" ]; then
            echo "  ✓ Will update: $old_ref -> $latest_tag"
            # Use sed to replace the ref for this specific module only
            # Escape special characters for sed
            mod_escaped=$(printf '%s\n' "$mod" | sed 's/[\/&]/\\&/g')
            old_ref_escaped=$(printf '%s\n' "$old_ref" | sed 's/[\/&]/\\&/g')
            latest_tag_escaped=$(printf '%s\n' "$latest_tag" | sed 's/[\/&]/\\&/g')
            # Replace only the ref for this specific module
            sed -i "/^mod '$mod_escaped'/,/^mod / s/:ref => '$old_ref_escaped'/:ref => '$latest_tag_escaped'/" "$TEMP_FILE"
        else
            echo "  Already up to date"
        fi
    else
        echo "  ⚠ Could not determine latest tag (network issue or no tags)"
    fi
    echo ""
done

# Show diff
echo "==========================================="
echo "Changes to be made:"
echo "==========================================="
diff -u "$TEMP_FILE" "$PUPPETFILE" || true

echo ""
echo "==========================================="
read -p "Apply these changes? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$TEMP_FILE" "$PUPPETFILE"
    echo "✓ Puppetfile updated successfully"
    echo "Backup saved as: $BACKUP_FILE"
    echo ""
    echo "Next steps:"
    echo "  1. Review the changes: git diff $PUPPETFILE"
    echo "  2. Test in dev: r10k puppetfile install -p"
    echo "  3. Deploy when ready"
else
    echo "✗ Changes discarded"
    rm "$BACKUP_FILE"
fi

rm "$TEMP_FILE"
