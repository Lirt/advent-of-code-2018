#!/usr/bin/env bash

# Declare associative array to store steps for each letter
declare -A steps

# Find missing letters and reverse their order
# Assume, that all letters from alphabet were used
v=$(grep -o "before step ." $1 | sort -u)
next_steps=""

for c in {A..Z}; do
  if ! grep -q "$c$" <<< "$v"; then
    next_steps+="$c"
  fi
done

next_steps=$(rev <<< "$next_steps")
echo "Initial processing list: $next_steps"

# Load steps into associative array sorted alphabetically
while read -r LINE; do
  l_first=$(grep -o "Step ." <<< "$LINE")
  l_next=$(grep -o "before step ." <<< "$LINE")
  steps["${l_first: -1}"]+="${l_next: -1}"
done < <(sort -t " " -k8 -k2 "$1")

# Main algorithm loop
counter=1
visited=""

while [ ! -z "$next_steps" ]; do
  requisities_complete=1
  current_letter="${next_steps: -$counter:1}"
  echo "current_letterrent letter: $current_letter"

  # Check if there are unmet requisities for node to be processed
  for k in "${!steps[@]}"; do
    if [[ "${steps["$k"]}" =~ "$current_letter" ]]; then
      requisities_complete=0
      break
    fi
  done

  # If all requisities to process current_letterrent node are not complete
  # continue with next letter.
  # Or expand letters from node into next steps
  if [ $requisities_complete -eq 0 ]; then
    ((++counter))
    continue
  else
    visited+="$current_letter"
    next_steps="${next_steps//$current_letter/}"
    # Expand new steps
    next_steps+="${steps["$current_letter"]}"
    # Reverse string
    next_steps=$(grep -o . <<< "$next_steps" | sort -r | tr -d "\n")
    unset steps["$current_letter"]
    counter=1
  fi
done

echo "Visited nodes steps: $visited"
