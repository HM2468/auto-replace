#!/bin/bash

cd /Users/miaohuang/repos/scripts/app/shell
# Define an array of origin paths
declare -a ORIGIN_PATHS=(
  "/Users/miaohuang/repos/scripts/app"
  "/Users/miaohuang/repos/scripts/output"
)

# Define an array of corresponding target paths
declare -a TARGET_PATHS=(
  "/Users/miaohuang/Desktop/tmp/auto-replace/app"
  "/Users/miaohuang/Desktop/tmp/auto-replace/output"
)

# Check if the number of origin paths and target paths are the same
if [ ${#ORIGIN_PATHS[@]} -ne ${#TARGET_PATHS[@]} ]; then
    echo "Error: The number of origin paths and target paths do not match."
    exit 1
fi

# Loop through all the paths
for (( i=0; i<${#ORIGIN_PATHS[@]}; i++ )); do
    # First, remove the existing target directory
    rm -rf "${TARGET_PATHS[$i]}"

    # Then, copy the new one from the origin
    cp -a "${ORIGIN_PATHS[$i]}" "${TARGET_PATHS[$i]}"

    # Check if copy was successful
    if [ $? -eq 0 ]; then
        echo "Copy successful for ${TARGET_PATHS[$i]}"
    else
        echo "Error during copy for ${TARGET_PATHS[$i]}"
    fi
done

cd /Users/miaohuang/Desktop/tmp/auto-replace
git add .
git commit -m "update"
git push