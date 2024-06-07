class JsonOptimizer
  require './json_methods.rb'
  include JsonMethods

  attr_reader :tar_lang

  def initialize(work_dirs: [], tar_lang: 'en')
    @work_dirs = work_dirs
    @tar_lang = tar_lang
    raise 'tar_lang error' unless %w(zh-CN en ru).include?(tar_lang)
    init_hash_path
    init_files
  end

  private

  def init_files
    @files = []
    @work_dirs.each do |work_dir|
      @files += Dir.glob("#{work_dir}/**/*").select { |e| File.file? e }.sort
    end

    @files = @files.reject do |file|
      file.include?('edu') ||
      file.include?('gitee_go') ||
      file.include?('message.json') ||
      file.include?('oversea-landing')
    end

    @ch_files = @files.select do |file|
      file.end_with?('.json') && file.include?('zh-CN')
    end

    @en_files = @files.select do |file|
      file.end_with?('.json') && (file.include?('/en/') || file.include?('en.'))
    end

    @ru_files = @files.select do |file|
      file.end_with?('.json') && (file.include?('/ru/') || file.include?('ru.'))
    end
  end

end