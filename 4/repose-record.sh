#!/usr/bin/env bash

declare -A total_sleep_dict
declare -A sleeping_schedule_dict

# Highest number of minutes asleep
max_asleep=0
gid_max_asleep=0

# Part 1
minute_max=0
minute_max_n=0

# Part2
minute_max_all=0
minute_max_all_n=0

function parse_minute() {
  : "${1#*:}"
  min=${_%%]*}

  # Convert two digit 0X number to single digit
  [[ $min =~ 0[0-9] ]] && min=${min[2]}

  echo "$min"
}

# Find the guard with most minutes asleep
while read -r LINE; do
  # Guard change
  if [[ "$LINE" =~ 'Guard #' ]]; then
    : "${LINE#*#}"
    gid=${_%% *}

  # Sleeping
  elif [[ "$LINE" =~ 'falls asleep' ]]; then
    sleep_start=$(parse_minute "$LINE")

  # Waking
  elif [[ "$LINE" =~ 'wakes up' ]]; then
    sleep_end=$(parse_minute "$LINE")

    # Increase sleep time of guard
    total_sleep_dict["$gid"]=$(( total_sleep_dict["$gid"] + (sleep_end - sleep_start) ))

    # Find guard ID and minutes asleep for most sleeping guard
    if [ ${total_sleep_dict["$gid"]} -gt $max_asleep ]; then
      max_asleep=${total_sleep_dict["$gid"]}
      gid_max_asleep=$gid
    fi

    # Create per Guard entry for total minutes asleep
    for (( i = sleep_start; i < sleep_end; i++ )); do
      if [ -z "${sleeping_schedule_dict["$gid:$i"]}" ]; then
        sleeping_schedule_dict["$gid:$i"]=1
      else
        ((++sleeping_schedule_dict["$gid:$i"]))
      fi
    done
  fi
done < <(sort "${1}")

# Part 1
# Find minute in which guard that sleeps most, sleeps most often
for (( i = 0; i < 60; i++ )); do
  if [ -n "${sleeping_schedule_dict["$gid_max_asleep:$i"]}" ]; then
    if [ ${sleeping_schedule_dict["$gid_max_asleep:$i"]} -gt $minute_max ]; then
      minute_max=${sleeping_schedule_dict["$gid_max_asleep:$i"]}
      minute_max_n=$i
    fi
  fi
done

# Part 2
# From all guards, find who sleeps the most in any minute and get his ID and exact minute
for (( i = 0; i < 60; i++ )); do
  for gid in "${!total_sleep_dict[@]}"; do
    if [ -n "${sleeping_schedule_dict["$gid:$i"]}" ]; then
      if [ ${sleeping_schedule_dict["$gid:$i"]} -gt $minute_max_all ]; then
        minute_max_all=${sleeping_schedule_dict["$gid:$i"]}
        minute_max_all_n=$i
        minute_max_all_gid=$gid
      fi
    fi
  done
done


echo "Most minutes slept in one minute for guard $gid_max_asleep: $minute_max"
echo "Minute in which guard $gid_max_asleep sleeps most: $minute_max_n"
echo "Guard ID $gid_max_asleep multiplied by minute in which he sleeps the most: $(( gid_max_asleep * minute_max_n ))"

echo "Above all, most minutes slept in one minute: $minute_max_all"
echo "Above all, minute in which guard sleeps most: $minute_max_all_n"
echo "Above all, guard ID multiplied by minute in which he sleeps the most: $(( minute_max_all_gid * minute_max_all_n ))"
