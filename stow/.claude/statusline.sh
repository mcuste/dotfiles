#!/bin/bash
# Claude Code status line script
# Receives JSON session data on stdin, outputs a single-line color-coded status bar.

set -euo pipefail

# -- Read JSON from stdin --

DATA=$(cat)

# -- Parse JSON fields with jq --

MODEL=$(echo "$DATA" | jq -r '.model.display_name // .model.id // "unknown"')
EFFORT=$(echo "$DATA" | jq -r '.effort.level // empty')
PROJECT_DIR=$(echo "$DATA" | jq -r '.workspace.project_dir // .workspace.current_dir // ""')
COST=$(echo "$DATA" | jq -r '.cost.total_cost_usd // 0')
INPUT_TOKENS=$(echo "$DATA" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_CREATE=$(echo "$DATA" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$DATA" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
OUTPUT_TOKENS=$(echo "$DATA" | jq -r '.context_window.current_usage.output_tokens // 0')
TOTAL_TOKENS=$(( INPUT_TOKENS + CACHE_CREATE + CACHE_READ + OUTPUT_TOKENS ))
CTX_USED=$(echo "$DATA" | jq -r '.context_window.used_percentage // 0')
CTX_USED=${CTX_USED%.*}
AGENT_NAME=$(echo "$DATA" | jq -r '.agent.name // empty')

# -- Colors --

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
DIM='\033[90m'
BOLD='\033[1m'
RESET='\033[0m'

# -- Project directory basename --

if [ -n "$PROJECT_DIR" ]; then
    DIR_NAME=$(basename "$PROJECT_DIR")
else
    DIR_NAME="unknown"
fi

# -- Build single output line --

OUT=""

# Model name (with effort level if present)
OUT="${OUT}🤖 ${CYAN}${MODEL}${RESET}"
if [ -n "$EFFORT" ]; then
    OUT="${OUT} ${DIM}(${EFFORT})${RESET}"
fi

# Agent name if present
if [ -n "$AGENT_NAME" ]; then
    OUT="${OUT} ${DIM}[${YELLOW}${AGENT_NAME}${DIM}]${RESET}"
fi

# Context percentage with color
CTX_INT=${CTX_USED%.*}
CTX_INT=${CTX_INT:-0}
if [ "$CTX_INT" -gt 100 ] 2>/dev/null; then CTX_INT=100; fi
if [ "$CTX_INT" -lt 0 ] 2>/dev/null; then CTX_INT=0; fi

if [ "$CTX_INT" -ge 90 ]; then
    CTX_COLOR="$RED"
elif [ "$CTX_INT" -ge 70 ]; then
    CTX_COLOR="$YELLOW"
else
    CTX_COLOR="$GREEN"
fi

# Build compact progress bar (10 chars)
BAR_WIDTH=10
FILLED=$(( (CTX_INT * BAR_WIDTH) / 100 ))
EMPTY=$(( BAR_WIDTH - FILLED ))
BAR_FILLED=""
BAR_EMPTY=""
for (( i=0; i<FILLED; i++ )); do BAR_FILLED="${BAR_FILLED}▓"; done
for (( i=0; i<EMPTY; i++ )); do BAR_EMPTY="${BAR_EMPTY}░"; done

if [ "$TOTAL_TOKENS" -ge 1000 ] 2>/dev/null; then
    TOKEN_FMT="$(( TOTAL_TOKENS / 1000 ))k"
else
    TOKEN_FMT="${TOTAL_TOKENS}"
fi
OUT="${OUT} ${DIM}|${RESET} 🧠 ${CTX_COLOR}${BAR_FILLED}${DIM}${BAR_EMPTY}${RESET} ${CTX_COLOR}${CTX_INT}%${RESET} ${DIM}(${TOKEN_FMT})${RESET}"

# Cost
COST_FMT=$(printf '$%.2f' "$COST" 2>/dev/null || echo '$0.00')
OUT="${OUT} ${DIM}|${RESET} 💰 ${COST_FMT}"


# Project directory (folder icon)
OUT="${OUT} ${DIM}|${RESET} 📁 ${BOLD}${DIR_NAME}${RESET}"

# Git branch
if [ -n "$PROJECT_DIR" ] && git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    BRANCH=$(git -C "$PROJECT_DIR" symbolic-ref --short HEAD 2>/dev/null || git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo "")
    if [ -n "$BRANCH" ]; then
        OUT="${OUT} ${DIM}|${RESET} 🌿 ${BRANCH}"
    fi
fi

# -- Output --

printf '%b\n' "$OUT"
