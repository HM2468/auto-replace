class OptimizeYML
  require './shared_methods.rb'
  include SharedMethods

  attr_reader :tar_lang, :type

  def initialize(work_dir: '', tar_lang: 'en', type: 'yml')
    @work_dir = work_dir
    @tar_lang = tar_lang
    @type = type
    raise 'tar_lang error' unless %w(zh-CN en ru).include?(tar_lang)
    raise 'type error' unless %w(yml json).include?(type)
    init_hash_path(type)
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
  end
end