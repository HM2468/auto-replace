class OptimizeJson
  require './shared_methods.rb'
  include SharedMethods

  attr_reader :tar_lang, :type

  def initialize(work_dirs: [], tar_lang: 'en', type: 'json')
    @work_dirs = work_dirs
    @tar_lang = tar_lang
    @type = type
    raise 'tar_lang error' unless %w(zh-CN en ru).include?(tar_lang)
    raise 'type error' unless %w(yml json).include?(type)

    init_hash_path(type)
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
  end

end