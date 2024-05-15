module SharedMethods
  require 'yaml'
  require 'json'
  require 'digest'

  def get_hashed_key(content, len: 32)
    raise "GET HASHED KEY ERR: len must be an integer" unless len.is_a?(Integer)
    raise "GET HASHED KEY ERR: len should be an even integer" unless len.even?

    Digest::SHA256.digest(content.to_s)[0,(len/2)].unpack('H*').first
  end

  def set_nested_hash_value(hash, keys, value)
    keys[0] = tar_lang if type == 'yml' && tar_lang != 'zh-CN'

    keys[0...-1].inject(hash) { |h, key| h[key] ||= {} }[keys[-1]] = value
  end

  def dig_nested_hash(hash, keys)
    keys.inject(hash) { |acc, key| acc&.fetch(key, nil) }
  end

  def recursive_get_hash(target_hash: {}, path: [], lang: 'zh-CN')
    target_hash.each do |key, value|
      current_path = path + [key.to_s]

      if value.is_a?(Hash)
        case lang
        when 'zh-CN'
          recursive_get_hash(target_hash: value, path: current_path, lang: 'zh-CN')
        when 'en'
          recursive_get_hash(target_hash: value, path: current_path, lang: 'en')
        end
      else
        final_key_path = current_path.join('==')
        case lang
        when 'zh-CN'
          final_key_path.gsub!('zh-CN==', '')
          uniq_key = get_hashed_key(final_key_path)
          @ch_keys_hash[uniq_key] = [final_key_path, get_hashed_key(value)]
        when 'en'
          final_key_path.gsub!('en==', '')
          uniq_key = get_hashed_key(final_key_path)
          @en_keys_hash[uniq_key] = [final_key_path, get_hashed_key(value)]
        end
        if value.is_a?(Array)
          case lang
          when 'zh-CN'
            @ch_keys_hash[uniq_key].pop
            iterate_nested_array!(uniq_key, value, :save_ch_hash)
          when 'en'
            @en_keys_hash[uniq_key].pop
            iterate_nested_array!(uniq_key, value, :save_en_hash)
          end
        else
          case lang
          when 'zh-CN'
            @ch_hash[get_hashed_key(value.to_s)] ||= value
          when 'en'
            @en_hash[get_hashed_key(value.to_s)] ||= value
          end
        end
      end
    end
  end

  def iterate_nested_array!(uniq_key, array, process_method)
    array.map! do |item|
      if item.is_a?(Array)
        iterate_nested_array!(uniq_key, item, process_method)
      else
        send(process_method, item, uniq_key)
      end
    end
  end

  def save_ch_hash(value, uniq_key)
    key = get_hashed_key(value.to_s)
    @ch_hash[key] ||= value
    @ch_keys_hash[uniq_key] << key
  end

  def save_en_hash(value, uniq_key)
    key = get_hashed_key(value.to_s)
    @en_hash[key] ||= value
    @en_keys_hash[uniq_key] << key
  end

  def read_en_hash(value, uniq_key)
    @en_hash[get_hashed_key(value)]
  end

  def read_ru_hash(value, uniq_key)
    @ru_hash[get_hashed_key(value)]
  end

  def recursive_set_hash(target_hash: {}, path: [])
    target_hash.each do |key, value|
      current_path = path + [key.to_s]
      if value.is_a?(Hash)
        recursive_set_hash(target_hash: value, path: current_path)
      else
        res = if value.is_a?(Array)
          uniq_key = get_hashed_key(current_path.join('==').gsub!('zh-CN==', ''))
          iterate_nested_array!(uniq_key, value, "read_#{tar_lang}_hash".to_sym)
        else
          translated_hash = instance_variable_get("@#{tar_lang}_hash")
          translated_hash[get_hashed_key(value)]
        end
        puts "key: #{current_path.inspect}, class: #{value.class}"
        target_hash = instance_variable_get("@tmp_#{tar_lang}_hash")
        set_nested_hash_value(target_hash, current_path, res)
      end
    end
  end

  def load_yml(path)
    YAML.load_file(path)
  end

  def load_json(path)
    JSON.parse(File.read(path))
  end

  def write_yml(hash, path, sorted: false, sorted_by_vlen: false)
    hash.sort!.to_h if sorted
    hash = if sorted_by_vlen
      hash.sort_by{ |k,v| v.to_s.size }.to_h
    else
      hash
    end
    File.open(path, 'w'){ |f| f.write(hash.to_yaml) }
  end

  def write_json(hash, path, sorted: false, sorted_by_vlen: false)
    hash.sort!.to_h if sorted
    hash = if sorted_by_vlen
      hash.sort_by{ |k,v| v.to_s.size }.to_h
    else
      hash
    end
    File.open(path, 'w'){ |f| f.write(JSON.pretty_generate(hash)) }
  end

  def init_hash_path(type)
    output_root = '/Users/miaohuang/repos/scripts/'
    @ch_path = output_root + "output/#{type}/ch.yml"
    @en_path = output_root + "output/#{type}/en.yml"
    @ch_keys_path = output_root + "output/#{type}/ch_keys.yml"
    @en_keys_path = output_root + "output/#{type}/en_keys.yml"
    @missing_path = output_root + "output/#{type}/missing.yml"
    @ch_hash = {}
    @en_hash = {}
    @ch_keys_hash = {}
    @en_keys_hash = {}
  end

  def merge_values
    output_root = '/Users/miaohuang/repos/scripts/'
    en_yml_path = output_root + "output/yml/en.yml"
    en_json_path = output_root + "output/json/en.yml"
    en_yml_hash = load_yml(en_yml_path)
    en_json_hash = load_yml(en_json_path)
    en_res_hash = en_json_hash.merge(en_yml_hash)
    write_yml(en_res_hash, en_json_path)
    write_yml(en_res_hash, en_yml_path)
  end

  def read_ch_files
    @ch_files.each do |file|
      puts file
      recursive_get_hash(target_hash: send("load_#{type}".to_sym, file))
    rescue => e
      puts "read_files error: \"#{file}\", err: \"#{e}\""
    end
    write_yml(@ch_hash, @ch_path)
    write_yml(@ch_keys_hash, @ch_keys_path)
  end

  def read_en_files
    @en_files.each do |file|
      puts file
      recursive_get_hash(target_hash: send("load_#{type}".to_sym, file), lang: 'en')
    rescue => e
      puts "read_files error: \"#{file}\", err: \"#{e}\""
    end
    write_yml(@en_hash, @en_path)
    write_yml(@en_keys_hash, @en_keys_path)
  end

  def compare
    @ch_hash = load_yml(@ch_path)
    @en_hash = load_yml(@en_path)
    keys = @ch_hash.keys - @en_hash.keys
    result_hash = @ch_hash.slice(*keys)
    # result_hash = result_hash.select{ |k,v| v =~ /.*[\u4E00-\u9FFF]+.*/}
    write_yml(result_hash, @missing_path, sorted_by_vlen: true)
  end

  def merge_missing
    @en_hash = load_yml(@en_path)
    @missing_hash = load_yml(@missing_path)
    @en_hash.merge!(@missing_hash)
    write_yml(@en_hash, @en_path)
  end

  def uniq_en_keys
    @ch_keys_hash = load_yml(@ch_keys_path)
    @en_keys_hash = load_yml(@en_keys_path)
    @ch_hash = load_yml(@ch_path)
    @en_hash = load_yml(@en_path)
    original_en_keys = []
    @ch_keys_hash.each do |k,v|
      if @en_keys_hash[k].nil?
        puts v
        next
      end
      v.each_with_index do |e, i|
        next if i.zero?

        ch_hash_key = e
        en_hash_key = @en_keys_hash[k][i]
        @en_hash[ch_hash_key] = @en_hash[en_hash_key]
        original_en_keys << en_hash_key
      end
    end
    original_en_keys.each do |k|
      @en_hash.delete(k)
    end
    write_yml(@en_hash, @en_path)
  end

  def reload_en_files
    @en_hash =  load_yml(@en_path)

    @ch_files.each do |file|
      reload_translated_hash(file)
    rescue => e
      puts "reload_files error: \"#{file}\", err: \"#{e}\""
    end
  end

  def reload_translated_hash(file)
    input_hash = send("load_#{type}".to_sym, file)
    target_path = file.gsub('zh-CN', tar_lang)
    instance_variable_set("@tmp_#{tar_lang}_hash", {})
    recursive_set_hash(target_hash: input_hash, path: [])
    res_hash = instance_variable_get("@tmp_#{tar_lang}_hash")
    send("write_#{type}".to_sym, res_hash, target_path)
  end

  def ch_regex
    /[\u4e00-\u9fa5]+/
  end
end