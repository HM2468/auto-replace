#!/bin/bash

# checkout to the right branch
cd /Users/miaohuang/work/gitee-ent-web
git reset .
git checkout .
git clean -f
git checkout russia/develop


# checkout to the right branch
cd /Users/miaohuang/work/gitee
git reset .
git checkout .
git clean -f
git checkout russia-integration

cd /Users/miaohuang/repos/gitee-ru-localization
git reset .
git checkout .
git clean -f
git checkout master
git branch -D sync_source
git checkout -b sync_source

cd /Users/miaohuang/repos/scripts/app/shell
# chmod +x sync_locales.sh

# Define an array of origin paths
declare -a ORIGIN_PATHS=(
    "/Users/miaohuang/work/gitee-ent-web/config/locales"
    "/Users/miaohuang/work/gitee-ent-web/packages/gitee-community-web/public/static/locales"
    "/Users/miaohuang/work/gitee/config/locales"
    "/Users/miaohuang/work/gitee/webpack/packages/gitee-locales"
)

# Define an array of corresponding target paths
declare -a TARGET_PATHS=(
    "/Users/miaohuang/repos/gitee-ru-localization/gitee-ent-web/config/locales"
    "/Users/miaohuang/repos/gitee-ru-localization/gitee-ent-web/packages/gitee-community-web/public/static/locales"
    "/Users/miaohuang/repos/gitee-ru-localization/Gitee/Config/locales"
    "/Users/miaohuang/repos/gitee-ru-localization/Gitee/webpack/packages/gitee-locales"
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

cd /Users/miaohuang/repos/gitee-ru-localization
git add .
git commit -m "sync from source code"
git push -f origin sync_source