#!/usr/bin/env bash

read -ra input < "$1"
total=0

function process_node() {
  local n_prev=$1
  local m_prev=$2
  local n=${input[0]}
  local m=${input[1]}

  # Read metadata of node and add it to total.
  # Or save current node.
  if [ $n -eq 0 ]; then
    for (( j = 0; j < m; j++ )); do
      total=$(( total + input[2 + j] ))
    done
    # Remove used node and metadata
    input=( "${input[@]::0}" "${input[@]:((2 + m))}" )
  else
    # Remove used node
    input=( "${input[@]::0}" "${input[@]:2}" )
    process_node "$((n - 1))" "$m"
  fi

  if [ $n_prev -eq 0 ]; then
    for (( j = 0; j < m_prev; j++ )); do
      total=$(( total + input[j] ))
    done
    # Remove used metadata
    input=( "${input[@]:((m_prev))}" )
  else
    if [ ${#input[@]} -ne 0 ]; then
      process_node "$((n_prev - 1))" "$m_prev"
    fi
  fi
}

process_node "${input[0]}" "${input[1]}"
echo "Total sum of metadata: $total"
