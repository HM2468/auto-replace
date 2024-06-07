module YmlMethods
  require 'yaml'
  require 'json'
  require 'digest'

  def get_hashed_key(content, len: 32)
    raise "GET HASHED KEY ERR: len must be an integer" unless len.is_a?(Integer)
    raise "GET HASHED KEY ERR: len should be an even integer" unless len.even?

    Digest::SHA256.digest(content.to_s)[0,(len/2)].unpack('H*').first
  end

  def set_nested_hash_value(hash, keys, value)
    keys[0] = tar_lang if tar_lang != 'zh-CN'

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
            #@en_hash[get_hashed_key(value.to_s)] ||= value
            @en_hash[uniq_key] ||= value
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
      tmp_str = current_path.join('==')
      tmp_str.gsub!('en==', '')
      uniq_key = get_hashed_key(tmp_str)
      if value.is_a?(Hash)
        recursive_set_hash(target_hash: value, path: current_path)
      else
        res = if value.is_a?(Array)
                iterate_nested_array!(uniq_key, value, "read_#{tar_lang}_hash".to_sym)
              else
                translated_hash = instance_variable_get("@#{tar_lang}_hash")
                translated_hash[uniq_key]
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

  def init_hash_path
    output_root = '/Users/miaohuang/repos/scripts/'
    @ch_path = output_root + "output/yml/ch.yml"
    @en_path = output_root + "output/yml/en.yml"
    @ch_keys_path = output_root + "output/yml/ch_keys.yml"
    @en_keys_path = output_root + "output/yml/en_keys.yml"
    @missing_path = output_root + "output/yml/missing.yml"
    @ch_hash = {}
    @en_hash = {}
    @ch_keys_hash = {}
    @en_keys_hash = {}
  end

  def merge_values
    output_root = '/Users/miaohuang/repos/scripts/'
    en_yml_path = output_root + "output/yml/en.yml"
    en_json_path = output_root + "output/json/en.yml"
    ch_yml_path = output_root + "output/yml/ch.yml"
    ch_json_path = output_root + "output/json/ch.yml"

    en_yml_hash = load_yml(en_yml_path)
    en_json_hash = load_yml(en_json_path)

    ch_yml_hash = load_yml(ch_yml_path)
    ch_json_hash = load_yml(ch_json_path)

    en_res_hash = en_json_hash.merge(en_yml_hash)
    ch_res_hash = ch_json_hash.merge(ch_yml_hash)

    write_yml(en_res_hash, en_yml_path)
    write_yml(en_res_hash, en_json_path)
    write_yml(ch_res_hash, ch_yml_path)

    yml_missing_path = output_root + "output/yml/missing.yml"
    json__missing_path = output_root + "output/json/missing.yml"
    yml_missing_hash = load_yml(yml_missing_path)
    json_missing_hash = load_yml(yml_missing_path)
    res_missing_hash = json_missing_hash.merge(yml_missing_hash)
    write_yml(res_missing_hash, yml_missing_path, sorted_by_vlen: true)
  end

  def combine
    output_root = '/Users/miaohuang/repos/scripts/'
    en_path = output_root + "output/yml/en.yml"
    ch_path = output_root + "output/yml/ch.yml"
    combine_path = output_root + "output/yml/combine.yml"
    ch_hash = load_yml(ch_path)
    en_hash = load_yml(en_path)
    combine_hash = {}
    ch_hash.each do |k, v|
      arr = []
      arr << v
      arr << en_hash[k]
      combine_hash[k] = arr
    end
    write_yml(combine_hash, combine_path)
  end

  def read_ch_files
    @ch_files.each do |file|
      puts file
      recursive_get_hash(target_hash: load_yml(file))
    rescue => e
      puts "read_files error: \"#{file}\", err: \"#{e}\""
    end
    write_yml(@ch_hash, @ch_path)
    write_yml(@ch_keys_hash, @ch_keys_path)
  end

  def read_en_files
    @en_files.each do |file|
      puts file
      recursive_get_hash(target_hash: load_yml(file), lang: 'en')
    rescue => e
      puts "read_files error: \"#{file}\", err: \"#{e}\""
    end
    write_yml(@en_hash, @en_path)
    write_yml(@en_keys_hash, @en_keys_path)
  end

  def reload_en_files
    @en_hash = load_yml(@en_path)
    @en_keys_hash = load_yml(@en_keys_path)

    @en_files.each do |file|
      reload_translated_hash(file)
    rescue => e
      puts "reload_files error: \"#{file}\", err: \"#{e}\""
    end
  end

  def reload_translated_hash(file)
    input_hash = load_yml(file)
    instance_variable_set("@tmp_#{tar_lang}_hash", {})
    recursive_set_hash(target_hash: input_hash, path: [])
    res_hash = instance_variable_get("@tmp_#{tar_lang}_hash")
    write_yml(res_hash, file)
  end

  def edit_ru_files
    @ru_files.each do |file|
      input_hash = load_yml(file)
      res_hash = modify_nested_hash!(input_hash)
      write_yml(res_hash, file)
    end
  end

  def edit_en_files
    @en_files.each do |file|
      input_hash = load_yml(file)
      res_hash = modify_nested_hash!(input_hash)
      write_yml(res_hash, file)
    end
  end

  def modify_hash_value(value)
    return value unless value.is_a?(String)

    regex = /\{([^}]*)\}/
    matches = value.scan(regex)
    arr = matches.flatten
    hash = {}
    if arr.size > 0
      arr.each do |item|
        key = get_hashed_key(item)
        hash[key] = item
      end
    end

    if arr.size > 0
      hash.each do |k,v|
        value.gsub!(v, k)
      end
    end

    value.gsub!(/oschina/i, 'gitlife')
    value.gsub!(/osc/i, 'gitlife')
    value.gsub!(/gitee/i, 'Gitlife')
    value.gsub!(/gitlife\.com/i, 'gitlife.ru')
    value.gsub!(/gitlife\.ru/i, 'gitlife.ru')
    value.gsub!(/Gitlife Enterprise Edition/i, 'Gitlife Professional')
    if arr.size > 0
      hash.each do |k,v|
        value.gsub!(k, v)
      end
    end
    value.gsub!("ca978112ca1bbdcafac231b39a23dc4d", 'a')
    value
  end

  def modify_nested_hash!(hash)
    hash.each do |key, value|
      if value.is_a?(Hash)
        modify_nested_hash!(value)
      else
        hash[key] = modify_hash_value(value)
      end
    end
    hash
  end

  def ch_regex
    /[\u4e00-\u9fa5]+/
  end
end