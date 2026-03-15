#!/usr/local/bin/bash

#############################################################################
# GitHub Issues Batch Creator
# Optimized for Bash 5+ (Homebrew) and GitHub CLI
#############################################################################

set -e

# Configuration
REPO="edshav/dcrdata" 
MILESTONE="v1"        
TASKS_FILE="tasks.json"

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Run: brew install jq"
    exit 1
fi

if [[ ! -f "$TASKS_FILE" ]]; then
    echo "Error: $TASKS_FILE not found!"
    exit 1
fi

# Associative array to map JSON index to GitHub Issue Number
declare -A ISSUE_MAP

echo "--- Starting Parent Issues Creation ---"

task_count=$(jq '.tasks | length' "$TASKS_FILE")

# Step 1: Create PARENT issues
for (( i=0; i<$task_count; i++ )); do
    type=$(jq -r ".tasks[$i].type" "$TASKS_FILE")
    
    if [[ "$type" == "parent" ]]; then
        title=$(jq -r ".tasks[$i].title" "$TASKS_FILE")
        description=$(jq -r ".tasks[$i].description" "$TASKS_FILE")
        assignee=$(jq -r ".tasks[$i].assignee" "$TASKS_FILE")
        
        echo -n "Creating parent: [$title]... "
        
        # Create issue and capture the URL
        url=$(gh issue create --repo "$REPO" \
                              --title "$title" \
                              --body "$description" \
                              --assignee "$assignee" \
                              --milestone "$MILESTONE" \
                              --label "enhancement")
        
        # Extract issue number from URL
        num=$(echo "$url" | grep -oE '[0-9]+$')
        ISSUE_MAP[$i]=$num
        echo "Success -> #$num"
    fi
done

echo ""
echo "--- Starting Sub-issues Creation ---"

# Step 2: Create SUB-ISSUES and link to parents
for (( i=0; i<$task_count; i++ )); do
    type=$(jq -r ".tasks[$i].type" "$TASKS_FILE")
    
    if [[ "$type" == "sub-issue" ]]; then
        title=$(jq -r ".tasks[$i].title" "$TASKS_FILE")
        parent_idx=$(jq -r ".tasks[$i].parent" "$TASKS_FILE")
        parent_num=${ISSUE_MAP[$parent_idx]}
        
        description=$(jq -r ".tasks[$i].description" "$TASKS_FILE")
        
        if [[ -z "$parent_num" ]]; then
            full_body="$description"
        else
            full_body="${description}"$'\n\n'"Part of #$parent_num"
        fi
        
        assignee=$(jq -r ".tasks[$i].assignee" "$TASKS_FILE")

        echo -n "Creating sub-issue: [$title] for #$parent_num... "
        
        gh issue create --repo "$REPO" \
                        --title "$title" \
                        --body "$full_body" \
                        --assignee "$assignee" \
                        --milestone "$MILESTONE" \
                        --label "enhancement" > /dev/null
        
        echo "Done!"
    fi
done

echo ""
echo "--- All tasks created successfully in $REPO ---"
