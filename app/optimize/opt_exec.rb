require './opt_json.rb'
require './opt_yml.rb'

# "/Users/miaohuang/repos/gitee-ru-localization/gitee-ent-web/config/locales"
# "/Users/miaohuang/repos/gitee-ru-localization/gitee-ent-web/packages/gitee-community-web/public/static/locales"
# "/Users/miaohuang/repos/gitee-ru-localization/Gitee/Config/locales"
# "/Users/miaohuang/repos/gitee-ru-localization/Gitee/webpack/packages/gitee-locales"

opt_yml = OptimizeYML.new(
  work_dir: "/Users/miaohuang/repos/gitee-ru-localization/Gitee/Config/locales",
  tar_lang: 'en'
)

opt_json = OptimizeJson.new(
  work_dirs: [
    "/Users/miaohuang/repos/gitee-ru-localization/gitee-ent-web/config/locales",
    "/Users/miaohuang/repos/gitee-ru-localization/gitee-ent-web/packages/gitee-community-web/public/static/locales",
    "/Users/miaohuang/repos/gitee-ru-localization/Gitee/webpack/packages/gitee-locales"
  ],
  tar_lang: 'en'
)

# # read origin file
# opt_yml.read_ch_files
# opt_json.read_ch_files
# opt_yml.read_en_files
# opt_json.read_en_files

# # use unique keys
# opt_yml.uniq_en_keys
# opt_json.uniq_en_keys

# # merge missing
# opt_yml.merge_missing
# opt_json.merge_missing

#opt_yml.reload_en_files
opt_json.reload_en_files