#!/bin/bash

# Script to fetch PRs associated with commits by specified username(s) for given year(s)
# and create a markdown file with PR titles and descriptions
#
# Usage: fetch-prs.sh [year...]
# If no years are specified, defaults to the current year.
# Examples:
#   fetch-prs.sh              # current year
#   fetch-prs.sh 2024         # just 2024
#   fetch-prs.sh 2023 2024    # both 2023 and 2024

# Parse year arguments (default to current year)
if [ $# -gt 0 ]; then
    YEARS=("$@")
else
    YEARS=("$(date +%Y)")
fi

# Repository path (default to current directory)
REPO_PATH="."

# Prompt for username(s)
echo "Enter GitHub username(s) (separate multiple usernames with spaces):"
read -r USERNAME_INPUT

# Trim whitespace and check if input is empty
USERNAME_INPUT=$(echo "$USERNAME_INPUT" | xargs)
if [ -z "$USERNAME_INPUT" ]; then
    echo "Error: No username provided"
    exit 1
fi

# Convert space-separated usernames to array
IFS=' ' read -ra USERNAMES <<< "$USERNAME_INPUT"

# Create author pattern for git log (username1\|username2\|...)
# Use printf to properly join with \| separator
AUTHOR_PATTERN=$(printf '%s\\|' "${USERNAMES[@]}" | sed 's/\\|$//')

# Create filename-safe username string (join multiple usernames with dash)
USERNAME_FOR_FILE=$(IFS='-'; echo "${USERNAMES[*]}")

# Build year label for filenames and headers
if [ ${#YEARS[@]} -eq 1 ]; then
    YEAR_LABEL="${YEARS[0]}"
else
    YEAR_LABEL=$(IFS='-'; echo "${YEARS[*]}")
fi

# Default output file with author name(s) and year(s)
OUTPUT_FILE="${USERNAME_FOR_FILE}-prs-${YEAR_LABEL}.md"

cd "$REPO_PATH" || exit 1

# Check if the directory is a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: $REPO_PATH is not a git repository"
    exit 1
fi

# Get the repository URL for commit links
REPO_URL=$(git config --get remote.origin.url | sed 's/\.git$//' | sed 's/^git@github\.com:/https:\/\/github.com\//')
if [ -z "$REPO_URL" ]; then
    REPO_URL=""
fi

echo "Fetching PRs from commits by $USERNAME_INPUT for year(s): ${YEARS[*]}..."

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is required but not found"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "Error: GitHub CLI is not authenticated"
    echo "Run: gh auth login"
    exit 1
fi

echo "GitHub CLI detected - fetching PR information..."

# Create markdown file with header
cat > "$OUTPUT_FILE" << EOF
# My Pull Requests - $YEAR_LABEL

Generated on: $(date +"%Y-%m-%d %H:%M:%S")

---

EOF

# Function to extract PR number from commit message
extract_pr_number() {
    local message="$1"
    # Look for patterns like #123, (#123), or "Merge pull request #123"
    local pattern1='\(#([0-9]+)\)'
    local pattern2='#([0-9]+)'

    if [[ "$message" =~ $pattern1 ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$message" =~ $pattern2 ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

TOTAL_ITEMS=0

for CURRENT_YEAR in "${YEARS[@]}"; do

echo ""
echo "=== Processing year $CURRENT_YEAR ==="

# Add year section header if multiple years
if [ ${#YEARS[@]} -gt 1 ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "# $CURRENT_YEAR" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Collect commits with their PR numbers and commit info (using simple arrays for bash 3.2 compatibility)
# We'll use parallel arrays to track: PR number, commit subject, commit body, commit hash
PR_NUMBERS_RAW=()
COMMIT_SUBJECTS=()
COMMIT_BODIES=()
COMMIT_HASHES=()

while IFS='|' read -r hash subject body; do
    PR_NUMBER=$(extract_pr_number "$subject $body")
    if [ -n "$PR_NUMBER" ]; then
        PR_NUMBERS_RAW+=("$PR_NUMBER")
        COMMIT_SUBJECTS+=("$subject")
        COMMIT_BODIES+=("$body")
        COMMIT_HASHES+=("$hash")
    fi
done < <(git log \
    --author="$AUTHOR_PATTERN" \
    --since="${CURRENT_YEAR}-01-01" \
    --until="${CURRENT_YEAR}-12-31" \
    --pretty=format:"%H|%s|%b")

# Store the count of commits with PR numbers
COMMITS_WITH_PRS=${#PR_NUMBERS_RAW[@]}

# If no PRs found in commits, try to get all PRs by author from GitHub for current year
if [ ${#PR_NUMBERS_RAW[@]} -eq 0 ]; then
    echo "No PR numbers found in commit messages, searching GitHub for PRs by author in $CURRENT_YEAR..."

    # Get PRs created by each username in current year
    for username in "${USERNAMES[@]}"; do
        while read -r pr_number; do
            if [ -n "$pr_number" ]; then
                PR_NUMBERS_RAW+=("$pr_number")
                COMMIT_SUBJECTS+=("")
                COMMIT_BODIES+=("")
                COMMIT_HASHES+=("")
            fi
        done < <(gh pr list --author "$username" --state all --search "created:${CURRENT_YEAR}-01-01..${CURRENT_YEAR}-12-31" --json number --jq '.[].number' 2>/dev/null)
    done
fi

# Create a deduplicated list while preserving the first occurrence's commit info
# We'll build a space-separated string of seen PR numbers for bash 3.2 compatibility
declare -a UNIQUE_PRS
declare -a UNIQUE_SUBJECTS
declare -a UNIQUE_BODIES
declare -a UNIQUE_HASHES
SEEN_PRS=""

for i in "${!PR_NUMBERS_RAW[@]}"; do
    pr="${PR_NUMBERS_RAW[$i]}"
    # Check if we've seen this PR number before
    if [[ ! " $SEEN_PRS " =~ " $pr " ]]; then
        UNIQUE_PRS+=("$pr")
        UNIQUE_SUBJECTS+=("${COMMIT_SUBJECTS[$i]}")
        UNIQUE_BODIES+=("${COMMIT_BODIES[$i]}")
        UNIQUE_HASHES+=("${COMMIT_HASHES[$i]}")
        SEEN_PRS="$SEEN_PRS $pr "
    fi
done

# Sort by PR number (need to sort parallel arrays together)
# Create a temporary array with indices
TEMP_SORT=()
for i in "${!UNIQUE_PRS[@]}"; do
    TEMP_SORT+=("${UNIQUE_PRS[$i]}:$i")
done

# Sort and extract sorted indices
SORTED_INDICES=($(printf '%s\n' "${TEMP_SORT[@]}" | sort -t: -k1 -n | cut -d: -f2))

# Build final sorted arrays
SORTED_PRS=()
SORTED_SUBJECTS=()
SORTED_BODIES=()
SORTED_HASHES=()
for idx in "${SORTED_INDICES[@]}"; do
    SORTED_PRS+=("${UNIQUE_PRS[$idx]}")
    SORTED_SUBJECTS+=("${UNIQUE_SUBJECTS[$idx]}")
    SORTED_BODIES+=("${UNIQUE_BODIES[$idx]}")
    SORTED_HASHES+=("${UNIQUE_HASHES[$idx]}")
done

PR_COUNT=${#SORTED_PRS[@]}

if [ $PR_COUNT -eq 0 ]; then
    echo "No pull requests found for $CURRENT_YEAR, fetching commits instead..."

    # Fetch all commits by the author for the current year
    COMMIT_COUNT=0
    while IFS='|' read -r hash subject body date; do
        if [ -n "$hash" ]; then
            COMMIT_COUNT=$((COMMIT_COUNT + 1))
            COMMIT_SHORT_HASH=$(echo "$hash" | cut -c1-7)

            echo "  Found commit $COMMIT_SHORT_HASH: $subject"

            echo "" >> "$OUTPUT_FILE"
            echo "## Commit #$COMMIT_COUNT: $subject" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "- **Commit:** \`$COMMIT_SHORT_HASH\`" >> "$OUTPUT_FILE"
            echo "- **Date:** $date" >> "$OUTPUT_FILE"
            if [ -n "$REPO_URL" ]; then
                echo "- **URL:** ${REPO_URL}/commit/${hash}" >> "$OUTPUT_FILE"
            fi
            echo "- **Full hash:** \`$hash\`" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"

            if [ -n "$body" ] && [ "$body" != "" ]; then
                echo "### Description" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
                echo "$body" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            else
                echo "*No description provided*" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi

            echo "---" >> "$OUTPUT_FILE"
        fi
    done < <(git log \
        --author="$AUTHOR_PATTERN" \
        --since="${CURRENT_YEAR}-01-01" \
        --until="${CURRENT_YEAR}-12-31" \
        --pretty=format:"%H|%s|%b|%ci" | sed 's/|\([^|]*\)$/|\1/' | awk -F'|' '{print $1"|"$2"|"$3"|"substr($4,1,10)}')

    if [ $COMMIT_COUNT -eq 0 ]; then
        echo "No commits found for $CURRENT_YEAR"
        echo "" >> "$OUTPUT_FILE"
        echo "*No pull requests or commits found for $CURRENT_YEAR.*" >> "$OUTPUT_FILE"
    else
        TOTAL_ITEMS=$((TOTAL_ITEMS + COMMIT_COUNT))
        echo "Found $COMMIT_COUNT commits for $CURRENT_YEAR"
    fi
else
    echo "Found $PR_COUNT unique pull requests for $CURRENT_YEAR, fetching details..."

    # Fetch details for each PR
    ENTRIES_WRITTEN=0
    for i in "${!SORTED_PRS[@]}"; do
        PR_NUMBER="${SORTED_PRS[$i]}"
        COMMIT_SUBJECT="${SORTED_SUBJECTS[$i]}"
        COMMIT_BODY="${SORTED_BODIES[$i]}"
        COMMIT_HASH="${SORTED_HASHES[$i]}"

        echo "  Fetching PR #$PR_NUMBER..."

        PR_DATA=$(gh pr view "$PR_NUMBER" --json number,title,body,state,createdAt,mergedAt,url,author 2>/dev/null)

        USE_PR_DATA=false
        if [ -n "$PR_DATA" ]; then
            PR_AUTHOR=$(echo "$PR_DATA" | jq -r '.author.login // ""')

            # Check if PR author is in the specified usernames
            AUTHOR_MATCH=false
            for username in "${USERNAMES[@]}"; do
                if [ "$PR_AUTHOR" = "$username" ]; then
                    AUTHOR_MATCH=true
                    break
                fi
            done

            if [ "$AUTHOR_MATCH" = true ]; then
                USE_PR_DATA=true
            else
                echo "  PR #$PR_NUMBER found but author is $PR_AUTHOR (not in specified usernames), using commit info instead"
            fi
        else
            echo "  PR #$PR_NUMBER not found in this repository, using commit info instead"
        fi

        # Increment entries counter
        ENTRIES_WRITTEN=$((ENTRIES_WRITTEN + 1))

        # Write entry to file
        echo "" >> "$OUTPUT_FILE"

        if [ "$USE_PR_DATA" = true ]; then
            # Use PR data
            PR_TITLE=$(echo "$PR_DATA" | jq -r '.title // ""')
            PR_BODY=$(echo "$PR_DATA" | jq -r '.body // ""')
            PR_STATE=$(echo "$PR_DATA" | jq -r '.state // ""')
            PR_URL=$(echo "$PR_DATA" | jq -r '.url // ""')
            PR_CREATED=$(echo "$PR_DATA" | jq -r '.createdAt // ""' | cut -d'T' -f1)
            PR_MERGED=$(echo "$PR_DATA" | jq -r '.mergedAt // ""' | cut -d'T' -f1)

            echo "## PR #$PR_NUMBER: $PR_TITLE" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "- **Author:** @$PR_AUTHOR" >> "$OUTPUT_FILE"
            echo "- **State:** $PR_STATE" >> "$OUTPUT_FILE"
            echo "- **Created:** $PR_CREATED" >> "$OUTPUT_FILE"

            if [ -n "$PR_MERGED" ] && [ "$PR_MERGED" != "null" ]; then
                echo "- **Merged:** $PR_MERGED" >> "$OUTPUT_FILE"
            fi

            echo "- **URL:** $PR_URL" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"

            if [ -n "$PR_BODY" ] && [ "$PR_BODY" != "null" ] && [ "$PR_BODY" != "" ]; then
                echo "### Description" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
                echo "$PR_BODY" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            else
                echo "*No description provided*" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        else
            # Use commit data as fallback
            if [ -n "$COMMIT_HASH" ]; then
                COMMIT_DATE=$(git show -s --format=%ci "$COMMIT_HASH" 2>/dev/null | cut -d' ' -f1)
                COMMIT_SHORT_HASH=$(echo "$COMMIT_HASH" | cut -c1-7)

                echo "## Commit (PR #$PR_NUMBER): $COMMIT_SUBJECT" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
                echo "- **Type:** Commit (PR not available)" >> "$OUTPUT_FILE"
                echo "- **Commit:** \`$COMMIT_SHORT_HASH\`" >> "$OUTPUT_FILE"
                echo "- **Date:** $COMMIT_DATE" >> "$OUTPUT_FILE"
                if [ -n "$REPO_URL" ]; then
                    echo "- **URL:** ${REPO_URL}/commit/${COMMIT_HASH}" >> "$OUTPUT_FILE"
                fi
                echo "" >> "$OUTPUT_FILE"

                if [ -n "$COMMIT_BODY" ] && [ "$COMMIT_BODY" != "" ]; then
                    echo "### Description" >> "$OUTPUT_FILE"
                    echo "" >> "$OUTPUT_FILE"
                    echo "$COMMIT_BODY" >> "$OUTPUT_FILE"
                    echo "" >> "$OUTPUT_FILE"
                else
                    echo "*No description provided*" >> "$OUTPUT_FILE"
                    echo "" >> "$OUTPUT_FILE"
                fi
            else
                # No commit info available (PR from GitHub API)
                echo "## PR #$PR_NUMBER" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
                echo "*PR details not available*" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        fi

        echo "---" >> "$OUTPUT_FILE"
    done

    TOTAL_ITEMS=$((TOTAL_ITEMS + ENTRIES_WRITTEN))
    echo "Found $ENTRIES_WRITTEN pull requests for $CURRENT_YEAR"
fi

done  # end of YEARS loop

# Add total count to file header
sed -i '' '/^Generated on:/a\
Total: '"$TOTAL_ITEMS"' items found\
' "$OUTPUT_FILE"

echo ""
echo "Done! Found $TOTAL_ITEMS total items across ${#YEARS[@]} year(s)"
echo "Output written to: $OUTPUT_FILE"
