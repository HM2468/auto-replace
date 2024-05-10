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

# 24～31 行是将gitee-ru-localization里所有的国际化文件读取到en.yml里
# 不用每次都执行, 根据需要注释
# opt_yml.read_ch_files
# opt_json.read_ch_files
# opt_yml.read_en_files
# opt_json.read_en_files
# opt_yml.uniq_en_keys
# opt_json.uniq_en_keys
# opt_yml.merge_missing
# opt_json.merge_missing
############################

# 手动替换后回填所有yaml文件，社区版json和yaml文件都有，根据需要注释
opt_yml.reload_en_files

# 手动替换后回填所有json文件，企业版只有json文件，根据需要注释
opt_json.reload_en_files