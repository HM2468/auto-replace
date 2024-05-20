#!/bin/bash

# execute this script
# ./diff.sh config/locales/config/locales/en.yml

# Check if a parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file-path>"
  exit 1
fi

# Assign the parameter to a variable
FILE_PATH=$1

# Define other paths
TMP_DIR="/Users/miaohuang/Desktop/tmp/diff_to_html"
WORK_DIR="/Users/miaohuang/repos/scripts"
DIFF_FILE="$TMP_DIR/changes.diff"
HTML_FILE="$TMP_DIR/changes.html"

cd "$TMP_DIR"
# Remove old diff and html files if they exist
if [ -f "$DIFF_FILE" ]; then
  rm "$DIFF_FILE"
  echo "Removed $DIFF_FILE"
fi

if [ -f "$HTML_FILE" ]; then
  rm "$HTML_FILE"
  echo "Removed $HTML_FILE"
fi

# Generate diff file
cd "$WORK_DIR"
git show "$FILE_PATH" > "$TMP_DIR/changes.diff"

cd "$TMP_DIR"
# Generate html
python diff_to_html.py "$TMP_DIR/changes.diff" "$TMP_DIR/changes.html"

