#!/usr/bin/env bash

# Run with:
#   ./the-sum-of-its-parts.sh <input-file> <workers_count> <timeout>

# Get decimal value of a letter
function letter_to_dec() {
  printf "%d\n" "'$1'"
}

# Get idle workers count
function get_idle_workers_count() {
  local count=0
  for (( i = 0; i < workers_count; i++ )); do
    echo "W['$i']: ${workers["$i.time"]}" 1>&2
    [ ${workers["$i.time"]} -eq 0 ] && ((++count))
  done
  echo "$count"
}

# Get minimal work amount from all assigned work
function get_min_work() {
  local min=99999
  for (( i = 0; i < workers_count; i++ )); do
    if [ "${workers["$i.time"]}" -ne 0 ]; then
      [ ${workers["$i.time"]} -lt $min ] && min=${workers["$i.time"]}
    fi
  done
  echo "$min"
}

function execute_work() {
  local min
  min=$(get_min_work)

  for (( i = 0; i < workers_count; i++ )); do
    # Save letter that was done
    if [ ${workers["$i.time"]} -eq $min ]; then
      letter_done=${workers["$i.letter"]}
    fi

    # Decrement work time
    if [ ${workers["$i.time"]} -ne 0 ]; then
      workers["$i.time"]=$(( workers["$i.time"] - min ))
      echo "Worker '$i' has done work on letter ${workers["$i.letter"]} and now has: ${workers["$i.time"]} minutes left" 1>&2
    fi
  done

  time_spent=$((time_spent + min))
  echo "Time spent now: $time_spent"
}

function assign_work() {
  letter="$1"
  for (( i = 0; i < workers_count; i++ )); do
    if [ ${workers["$i.time"]} -eq 0 ]; then
      letter_ascii_val=$(letter_to_dec "$letter")
      workers["$i.time"]=$((letter_ascii_val + timeout - A_val))
      workers["$i.letter"]=$letter
      break
    fi
  done
}

# Constants
A_val=64

# Variables
workers_count=$2
timeout=$3
time_spent=0

# Declare associative array for workers and nullify it
declare -A workers
for (( i = 0; i < workers_count; i++ )); do
  workers["$i.letter"]=""
  workers["$i.time"]=0
done

# Declare associative array to store steps for each letter
declare -A steps

# Find missing letters and reverse their order.
# Assume, that all letters from alphabet were used.
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

# Execute until there is work to be done and workers are doing something
while [ ! -z "$next_steps" ] || [ $(get_idle_workers_count) -ne $workers_count ]; do

  # If there is no work or all workers are occupied,
  # or no work can be done yet, execute assigned work
  if [ -z "$next_steps" ] || [ $(get_idle_workers_count) -eq 0 ] || [ $counter -gt ${#next_steps} ]; then
    # `letter_done` is assigned inside `execute_work` function
    execute_work
    echo "Letter $letter_done was done"
    # Expand new steps
    next_steps+="${steps["$letter_done"]}"
    # Reverse string
    next_steps=$(grep -o . <<< "$next_steps" | sort -r | tr -d "\n")
    echo "Processing list: $next_steps"
    unset steps["$letter_done"]
    counter=1
    continue
  fi

  requisities_complete=1
  cur="${next_steps: -$counter:1}"

  # Check if there are unmet requisities for node to be processed
  for k in "${!steps[@]}"; do
    if [[ "${steps["$k"]}" =~ "$cur" ]]; then
      requisities_complete=0
      break
    fi
  done

  # If all requisities to process current node are not complete
  # continue with next letter.
  # Or assign work
  if [ $requisities_complete -eq 0 ]; then
    ((++counter))
    continue
  else
    echo "Assigning work with letter $cur"
    assign_work "$cur"
    next_steps="${next_steps//$cur/}"
  fi
done

echo "Total time spent: $time_spent"
