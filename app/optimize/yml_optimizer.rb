class YmlOptimizer
    require './yml_methods.rb'
    include YmlMethods

    attr_reader :tar_lang

    def initialize(work_dir: '', tar_lang: 'en')
      @work_dir = work_dir
      @tar_lang = tar_lang
      raise 'tar_lang error' unless %w(zh-CN en ru).include?(tar_lang)
      init_hash_path
      init_files
    end

    private

    def init_files
      @files = Dir.glob("#{@work_dir}/**/*").select { |e| File.file? e }.sort
      @ch_files = @files.select do |file|
        file.end_with?('.yml') && file.include?('zh-CN.') && !file.include?('locales/enterprise_image')
      end
      @en_files = @files.select do |file|
        file.end_with?('.yml') && file.include?('en.') && !file.include?('locales/enterprise_image')
      end
      @ru_files = @files.select do |file|
        file.end_with?('.yml') && file.include?('ru.') && !file.include?('locales/enterprise_image')
      end
    end
  end