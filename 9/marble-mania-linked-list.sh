#!/usr/bin/env bash

counter=0

# Insert element to linked list and move ID pointer to it
function ll_insert() {
  # Usage: ll_insert "ll" "id" "value"
  #   ll: name of linked list associative array variable
  #   id: ID of element after which new element will be inserted
  #   value: value of new element
  local -n ll_ref="$1"
  local -n id_current="$2"
  local value="$3"

  # Generating UUIDs is too expensive
  # Get an incremented number as ID
  # id_new=$(uuid)
  local id_new=$counter
  ((++counter))

  if [ -v "ll_ref[@]" ]; then
    # Save next uuid
    next_id=${ll_ref["$id_current.next"]}

    # Create new element with previous pointer set to current
    # and next set to former next
    ll_ref["$id_new.value"]="$value"
    ll_ref["$id_new.prev"]="$id_current"
    ll_ref["$id_new.next"]="$next_id"

    # Replace next of current node
    # Replace previous pointer of former next
    ll_ref["$id_current.next"]="$id_new"
    ll_ref["$next_id.prev"]="$id_new"
  else
    ll_ref["$id_new.value"]="$value"
    ll_ref["$id_new.next"]="$id_new"
    ll_ref["$id_new.prev"]="$id_new"
    id_current="$id_new"
  fi
}

# Remove element pointed by id from linked list
# and move id pointer to next
function ll_remove() {
  # Usage: ll_remove "ll" "id"
  #   ll: name of linked list associative array variable
  #   id: ID of element which will be removed
  local -n ll_ref="$1"
  local -n id="$2"
  id_prev=${ll_ref["$id.prev"]}
  id_next=${ll_ref["$id.next"]}

  # Rearrange pointers
  ll_ref["$id_prev.next"]="$id_next"
  ll_ref["$id_next.prev"]="$id_prev"

  # Remove element
  unset ll_ref["$id.value"]
  unset ll_ref["$id.next"]
  unset ll_ref["$id.prev"]

  # Set current element to next
  id="$id_next"
}

# Declare variables
declare -A ll
declare -A score
player_id=1
current=""

# Parse input
players=$(grep -Eo "^[[:digit:]]+" "$1")
points=$(grep -Eo "[[:digit:]]+ points$" "$1" | awk '{print $1}')
echo "Number of players: $players"
echo "Last marble: $points"

# Initialize linked list
ll_insert "ll" "current" "0"


# Main loop
for (( i = 1; i <= points; i++ )); do
  current=${ll["$current.next"]}

  if (( i % 23 == 0 )); then
    echo "$i"
    # Handle 23
    # Move 7 + 1 marbles to left
    for (( j = 0; j < 8; j++ )); do
      current=${ll["$current.prev"]}
    done

    # Increment score
    if [ -z "${score["$player_id"]}" ]; then
      score["$player_id"]=${ll["$current.value"]}
    else
      score["$player_id"]=$(( score["$player_id"] + ll["$current.value"] ))
    fi
    score["$player_id"]=$(( score["$player_id"] + i ))

    # Remove element
    ll_remove "ll" "current"
  else
    ll_insert "ll" "current" "$i"
    current=${ll["$current.next"]}
  fi

  if [ $player_id -eq "$players" ]; then
    player_id=1
  else
    ((++player_id))
  fi
done

max=0
for n in "${score[@]}"; do
  [ $n -gt $max ] && max=$n
done
echo "Highest score is: $max"
