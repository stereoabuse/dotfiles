#!/bin/sh
# Claude Code status line script

input=$(cat)

# Model
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# Context window token progress bar
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used_pct" ]; then
  # Build a 10-char progress bar
  filled=$(echo "$used_pct" | awk '{printf "%d", int($1 / 10 + 0.5)}')
  bar=""
  i=0
  while [ "$i" -lt 10 ]; do
    if [ "$i" -lt "$filled" ]; then
      bar="${bar}█"
    else
      bar="${bar}░"
    fi
    i=$((i + 1))
  done
  used_pct_display=$(printf "%.0f" "$used_pct")
  token_bar="[${bar}] ${used_pct_display}%"
else
  token_bar="[░░░░░░░░░░] 0%"
fi

# 5-hour rate limit
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

if [ -n "$five_pct" ]; then
  five_display=$(printf "%.0f" "$five_pct")
  resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  if [ -n "$resets_at" ]; then
    reset_time=$(date -r "$resets_at" +"%l:%M%p" | tr '[:upper:]' '[:lower:]' | sed 's/^ //')
    five_str="5h cap: ${five_display}% (resets ${reset_time})"
  else
    five_str="5h cap: ${five_display}%"
  fi
else
  five_str="5h cap: -"
fi

printf "%s  ctx:%s  %s" "$model" "$token_bar" "$five_str"
