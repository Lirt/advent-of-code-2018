#!/usr/bin/env bash

read -ra input < "$1"
declare -a node_list

# node_dict has these keys:
#  val - Overall value of node
#  len - Number of childs
#  1..N - Values of childs
declare -A node_dict

i=0
nid=0

# Iterate over input until the end is reached
while [ $i -lt ${#input[@]} ]; do

  # Read number of nodes (n) and length of metadata (m)
  n="${input[$i]}"
  m="${input[((i + 1))]}"
  i="$(( i + 2 ))"
  total=0

  # Read metadata of node and add it to total.
  # Or save current node.
  if [ $n -eq 0 ]; then
    for (( j = 0; j < m; j++ )); do
      total=$(( total + input[i + j] ))
    done
    i=$(( i + m ))

    # Write value of node to backlog
    if [ -z "${node_dict["$nid.len"]}" ]; then
      node_dict["$nid.len"]=1
      node_dict["$nid.val"]=0
      node_dict["$nid.1"]=$total
    else
      ((++node_dict["$nid.len"]))
      len=${node_dict["$nid.len"]}
      node_dict["$nid.$len"]=$total
    fi
  else
    node_list+=( "$n" )
    node_list+=( "$m" )
    ((++nid))
    node_dict["$nid.len"]=0
    node_dict["$nid.val"]=0
  fi

  # Cycle over previous nodes if they have n=0 (if we already visited all its childs)
  while [ ${#node_list[@]} -ne 0 ] &&
        [ ${node_list[-2]} -eq 0 ]; do
    m=${node_list[-1]}
    for (( j = 0; j < m; j++ )); do
      index=$((input[i + j]))
      # Check if index exists and calculate final node value
      if [ $index -le ${node_dict["$nid.len"]} ]; then
        node_dict["$nid.val"]=$(( node_dict["$nid.val"] + node_dict["$nid.$index"] ))
      fi
    done
    i=$(( i + m ))

    # Remove last 2 elements - node_list members n and m
    node_list=( "${node_list[@]::((${#node_list[@]} - 2))}" )

    # Add value of current node to previous
    nid_prev=$((nid - 1))
    ((++node_dict["$nid_prev.len"]))
    nid_prev_len=${node_dict["$nid_prev.len"]}
    node_dict["$nid_prev.$nid_prev_len"]=${node_dict["$nid.val"]}
    ((--nid))
  done

  # Decrement previous node counter
  if [ ${#node_list[@]} -ne 0 ]; then
    ((--node_list[-2]))
  fi
done

echo "Value of root node (Node with ID 0): ${node_dict["1.val"]}"
