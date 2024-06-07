require './yml_optimizer.rb'

class YmlExecutor
  def initialize
    @opt_yml = YmlOptimizer.new(
      work_dir: "/Users/miaohuang/repos/gitee-locales/Gitee/Config/locales",
      tar_lang: 'en'
    )
  end

  def read_en_files
    @opt_yml.read_en_files
  end

  def reload_yml_content
    @opt_yml.reload_en_files
  end

  def edit_ru_files
    @opt_yml.edit_ru_files
  end

  def edit_en_files
    @opt_yml.edit_en_files
  end
end

executor = YmlExecutor.new

# 读取文件到output, 不用每次执行
#executor.read_en_files
executor.reload_yml_content



























