require './json_optimizer.rb'

class JsonExecutor
  def initialize
    @opt_json = JsonOptimizer.new(
      work_dirs: [
        "/Users/miaohuang/repos/gitee-locales/gitee-ent-web/config/locales",
        "/Users/miaohuang/repos/gitee-locales/gitee-ent-web/packages/gitee-community-web/public/static/locales",
        "/Users/miaohuang/repos/gitee-locales/Gitee/webpack/packages/gitee-locales"
      ],
      tar_lang: 'en'
    )
  end

  def read_en_files
    @opt_json.read_en_files
  end

  def reload_json_content
    @opt_json.reload_en_files
  end

  def edit_ru_files
    @opt_json.edit_ru_files
  end

  def edit_en_files
    @opt_json.edit_en_files
  end
end

executor = JsonExecutor.new
# 读取文件到output, 不用每次执行
# executor.read_en_files
executor.reload_json_content



