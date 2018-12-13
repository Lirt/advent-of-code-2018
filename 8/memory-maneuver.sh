#!/usr/bin/env bash

read -ra input < "$1"
declare -a node_list

i=0
total=0

# Iterate over input until the end is reached
while [ $i -lt ${#input[@]} ]; do

  # Read number of nodes (n) and length of metadata (m)
  n="${input[$i]}"
  m="${input[((i + 1))]}"
  i="$(( i + 2 ))"

  # Read metadata of node and add it to total.
  # Or save current node.
  if [ $n -eq 0 ]; then
    for (( j = 0; j < m; j++ )); do
      total=$(( total + input[i + j] ))
    done
    i=$(( i + m ))
  else
    node_list+=( "$n" )
    node_list+=( "$m" )
  fi

  # Cycle over previous nodes if they have n=0 or if we already visited all its childs
  while [ ${#node_list[@]} -ne 0 ] &&
        [ ${node_list[-2]} -eq 0 ]; do
    m=${node_list[-1]}
    for (( j = 0; j < m; j++ )); do
      total=$(( total + input[i + j] ))
    done
    i=$(( i + m ))

    # Remove last 2 elements - node_list members n and m
    node_list=( "${node_list[@]::((${#node_list[@]} - 2))}" )
  done

  # Decrement previous node counter
  if [ ${#node_list[@]} -ne 0 ]; then
    # ((--node_list[${#node_list[@]} - 2]))
    ((--node_list[-2]))
  fi
done

echo "Total sum of metadata: $total"
