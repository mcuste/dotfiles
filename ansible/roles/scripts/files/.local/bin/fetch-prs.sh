#!/usr/bin/env bash

# Print a markdown report of GitHub PRs.
#
# Usage: fetch-prs.sh [-f] [-a login] [-r owner/repo]... [period...]
#   -f        include PR descriptions
#   -a login  report PRs of this GitHub user (default: you)
#   -r repo   report this repository; repeat for more (default: repository of the current directory)
#   period    PR creation year or quarter, for example 2026 or 2025-Q4 (default: current year)

set -euo pipefail

author="@me"
full=false
repos=()
while getopts "fa:r:" opt; do
    case "$opt" in
        f) full=true ;;
        a) author="$OPTARG" ;;
        r) repos+=("$OPTARG") ;;
        *) echo "Usage: fetch-prs.sh [-f] [-a login] [-r owner/repo]... [period...]" >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -gt 0 ]; then
    periods=("$@")
else
    periods=("$(date +%Y)")
fi

# An empty name selects the repository of the current directory.
if [ ${#repos[@]} -eq 0 ]; then
    repos=("")
fi

quarter_first_days=(01-01 04-01 07-01 10-01)
quarter_last_days=(03-31 06-30 09-30 12-31)

# Set first_day and last_day for a period like 2026 or 2025-Q4.
set_period_days() {
    local year quarter
    case "$1" in
        [0-9][0-9][0-9][0-9])
            first_day="$1-01-01"
            last_day="$1-12-31"
            ;;
        [0-9][0-9][0-9][0-9]-[Qq][1-4])
            year="${1%%-*}"
            quarter="${1: -1}"
            first_day="$year-${quarter_first_days[quarter - 1]}"
            last_day="$year-${quarter_last_days[quarter - 1]}"
            ;;
        *)
            echo "Error: invalid period '$1'. Use a year (2026) or a quarter (2025-Q4)." >&2
            exit 1
            ;;
    esac
}

status='{{.state}}, created {{slice .createdAt 0 10}}{{if .mergedAt}}, merged {{slice .mergedAt 0 10}}{{end}}'
if [ "$full" = true ]; then
    fields="number,title,state,createdAt,mergedAt,url,body"
    template='{{range .}}## #{{.number}} {{.title}}

'"$status"'
{{.url}}

{{if .body}}{{.body}}{{else}}*No description*{{end}}

---

{{end}}'
else
    fields="number,title,state,createdAt,mergedAt,url"
    template='{{range .}}- #{{.number}} {{.title}} ('"$status"') {{.url}}
{{end}}'
fi

# Filter commits by GitHub account, because one account can commit with several emails.
if [ "$author" = "@me" ]; then
    author_id=$(gh api graphql -f query='{ viewer { id } }' --jq '.data.viewer.id')
else
    author_id=$(gh api graphql -f login="$author" \
        -f query='query($login:String!) { user(login:$login) { id } }' --jq '.data.user.id')
fi

# Warn about commits on the default branch that have no PR, because the report does not show them.
warn_commits_without_pr() {
    local commits count
    commits=$(gh api graphql --paginate \
        -F owner='{owner}' -F name='{repo}' \
        -f id="$author_id" \
        -f since="${first_day}T00:00:00Z" \
        -f until="${last_day}T23:59:59Z" \
        -f query='
query($owner:String!, $name:String!, $id:ID!, $since:GitTimestamp!, $until:GitTimestamp!, $endCursor:String) {
  repository(owner:$owner, name:$name) {
    defaultBranchRef { target { ... on Commit {
      history(first:100, after:$endCursor, since:$since, until:$until, author:{id:$id}) {
        pageInfo { hasNextPage endCursor }
        nodes { abbreviatedOid messageHeadline associatedPullRequests { totalCount } }
      }
    } } }
  }
}' \
        --jq '.data.repository.defaultBranchRef.target.history.nodes[]
              | select(.associatedPullRequests.totalCount == 0)
              | "  \(.abbreviatedOid) \(.messageHeadline)"')

    [ -z "$commits" ] && return 0
    count=$(wc -l <<< "$commits" | tr -d ' ')
    {
        echo "warning: $count commits in $label have no PR and are not in this report:"
        head -n 5 <<< "$commits"
        [ "$count" -gt 5 ] && echo "  ..."
        true
    } >&2
}

for repo in "${repos[@]}"; do
    if [ -n "$repo" ]; then
        export GH_REPO="$repo"
    fi

    for period in "${periods[@]}"; do
        set_period_days "$period"
        label="${repo:+$repo }$period"
        echo "# Pull requests $label"
        echo

        report=$(gh pr list --author "$author" --state all --limit 1000 \
            --search "created:${first_day}..${last_day} sort:created-asc" \
            --json "$fields" --template "$template")

        if [ -n "$report" ]; then
            echo "$report"
        else
            echo "*No pull requests found.*"
        fi
        echo

        warn_commits_without_pr
    done
done
