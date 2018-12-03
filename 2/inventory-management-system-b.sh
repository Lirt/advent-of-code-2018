#!/usr/bin/env bash
#
###
# USAGE: ./inventory-management-system-b.sh < input.txt
###

# Read words into array
mapfile -t words < "${1:-/dev/stdin}"

# Iterate over each word with all words after it
for (( i = 0; i < ${#words[@]}; i++ )); do
  for (( j = i + 1; j < ${#words[@]}; j++ )); do
    word1=${words[$i]}
    word2=${words[$j]}
    dist=0

    # Iterate over each letter of word
    # and calculate Hamming Distance
    for (( k = 0; k < ${#words[$i]}; k++ )); do
      if [ ${word1:$k:1} != ${word2:$k:1} ]; then
        dist=$((dist + 1))
        diff_index=$k
      fi
      if [ $dist -gt 1 ]; then
        break
      fi
    done

    # If Hamming Distance is 1, we found the word
    if [ $dist -eq 1 ]; then
      echo "${word1:0:diff_index}${word1:((diff_index + 1))}"
    fi
  done
done
