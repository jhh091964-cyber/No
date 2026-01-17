#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# Usage:
#   ./unzip_all.sh [base_dir]
#   ./unzip_all.sh --cleanup [base_dir]
# Default base_dir: current directory

cleanup=0
base_dir="."

if [[ $# -gt 0 ]]; then
  if [[ "$1" == "--cleanup" ]]; then
    cleanup=1
    base_dir="${2:-.}"
  else
    base_dir="$1"
  fi
fi

if [[ ! -d "$base_dir" ]]; then
  echo "Base directory not found: $base_dir" >&2
  exit 1
fi

if [[ "$cleanup" -eq 0 ]]; then
  # Unzip mode
  mapfile -t zips < <(find "$base_dir" -maxdepth 1 -type f -name "*.zip")
  if (( ${#zips[@]} == 0 )); then
    echo "No zip files found in: $base_dir"
    exit 0
  fi
  printf "Found %d zip files in %s\n" "${#zips[@]}" "$base_dir"
  for zip in "${zips[@]}"; do
    dir="$(dirname "$zip")"
    name="$(basename "$zip" .zip)"
    out="$dir/$name"
    mkdir -p "$out"
    unzip -o -q "$zip" -d "$out"
    echo "Unzipped: $zip -> $out"
  done
  printf "\nAll zips processed.\n"
else
  # Cleanup mode: remove __MACOSX dirs recursively and root-level zips
  echo "Cleaning __MACOSX directories under: $base_dir"
  find "$base_dir" -type d -name "__MACOSX" -exec rm -rf {} +
  echo "Removing root-level zip files in: $base_dir"
  find "$base_dir" -maxdepth 1 -type f -name "*.zip" -exec rm -f {} +
  echo "Cleanup completed."
fi