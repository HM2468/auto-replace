require './opt_json.rb'
require './opt_yml.rb'

class OptExecutor
  def initialize
    @opt_yml = OptimizeYML.new(
      work_dir: "/Users/miaohuang/repos/gitee-locales/Gitee/Config/locales",
      tar_lang: 'en'
    )
    @opt_json = OptimizeJson.new(
      work_dirs: [
        "/Users/miaohuang/repos/gitee-locales/gitee-ent-web/config/locales",
        "/Users/miaohuang/repos/gitee-locales/gitee-ent-web/packages/gitee-community-web/public/static/locales",
        "/Users/miaohuang/repos/gitee-locales/Gitee/webpack/packages/gitee-locales"
      ],
      tar_lang: 'en'
    )
  end

  def read_locale_files
    @opt_yml.read_ch_files
    @opt_json.read_ch_files
    @opt_yml.read_en_files
    @opt_json.read_en_files
    @opt_yml.uniq_en_keys
    @opt_json.uniq_en_keys
    # @opt_json.compare
    # @opt_yml.compare
    @opt_yml.merge_missing
    @opt_json.merge_missing
    @opt_yml.merge_values
  end

  def combine
    @opt_yml.combine
  end

  def sync_corrected_content
    @opt_yml.merge_values
    @opt_yml.reload_en_files
    @opt_json.reload_en_files
  end
end

executor = OptExecutor.new

# 读取 gitee-locales 里文件到 output/locales
# 不用每次执行，按需注释
#executor.read_locale_files

# 合并en.yml 和 ch.yml 到一个文件中
# 不用每次执行，按需注释
# executor.combine

# 将校正后的翻译内容sync到gitee-locales
executor.sync_corrected_content
