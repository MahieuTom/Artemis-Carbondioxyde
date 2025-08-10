#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# Collect available serial ports
ports=(/dev/cu.*)

if ((${#ports[@]} == 0)); then
  echo "No /dev/cu.* devices found."
  echo "Tip: (un)plug your device or check permissions, then try again."
  exit 1
fi

echo "Select a serial port:"
select port in "${ports[@]}" "Quit"; do
  if [[ "$port" == "Quit" ]]; then
    exit 0
  elif [[ -n "${port:-}" ]]; then
    break
  else
    echo "Invalid selection. Try again."
  fi
done

# Allow optional extra args to idf.py after 'flash monitor', e.g. --baud 460800
extra_args=("$@")

echo "Running: idf.py -p \"$port\" flash monitor ${extra_args[*]}"
exec idf.py -p "$port" flash monitor "${extra_args[@]}"