require_relative '../../modules/file_manager'

module UtilsCR
  include FileManager

  SEED_URL_PARAM = '--seed_url'
  SEED_PATH_PARAM = '--seed_path'
  LEVEL_PARAM = '--level'
  LINE_BREAK = "\n"
  COMMA_SEP = ','
  RETAILER = "###RETAILER"

  # @param [MainResult] result
  # @param [String] mode
  # @param [String] file_path
  def write_result(result, mode, file_path)
    case mode
    when 'job'
      str_result = job_format(result)
    when 'cmd'
      str_result = cmd_format(result)
    else
      str_result = "PAY ATTENTION!!! Incorrect mode: #{mode.inspect}. Check your command '--mode' and read.me file."
    end
    write_to_file(file_path, str_result)
  end

  # @param [MainResult] result
  def job_format(result)
    sort(result)
    do_job_format(group_by(result.get_all, 'retailer'))
  end

  def cmd_format(result)
    sort(result)
    do_cmd_format(group_by(result.get_all, 'retailer'))
  end

  # @param [Hash] group
  def do_job_format(group)
    @current_level = nil
    group.each do |retailer, cats|
      add_retailer(retailer)
      group_by(cats, 'level').each do |level, cats_array|
        cats_array.each_with_index do |category, index|
          add_level(level)
          line = "\"#{category.breadcrumb.strip}\": \"#{category.url.strip}\""
          line += COMMA_SEP if index < cats_array.count - 1
          add_line(line)
        end
      end
      add_line(LINE_BREAK)
    end
    @str_result
  end

  def do_cmd_format(group)
    seed_url = SEED_URL_PARAM
    seed_path = SEED_PATH_PARAM
    group.each do |retailer, cats|
      add_retailer(retailer)
      group_by(cats, 'level').each do |level, cats_array|
        cats_array.each_with_index do |category, index|
          add_level(level)
          seed_url += " \"#{category.url.strip}\""
          seed_path += " \"#{category.breadcrumb.strip}\""
        end
        add_cmd(seed_url, seed_path, level)
      end
    end
    @str_result
  end

  ##### HALPERS #####

  # @param [Array] categories
  # @return [Hash] {:key1 => [categories], :key2 => [categories]}
  def group_by(categories, key)
    categories.each_with_object({}) do |res, hash|
      if hash[res.get(key)].nil?
        hash[res.get(key)] = []
        hash[res.get(key)] << res
      else
        hash[res.get(key)] << res
      end
    end
  end

  def add_line(line)
    if @str_result.nil?
      @str_result = "#{line}\n"
    else
      @str_result += "#{line}\n"
    end
  end

  def add_level(category_level)
    if @current_level.nil?
      add_line("///level: #{category_level}")
      @current_level = category_level
    elsif @current_level != category_level
      add_line("///level: #{category_level}")
      @current_level = category_level
    end
  end

  def add_retailer(retailer)
    add_line(RETAILER + ': ' + retailer)
  end


  def add_cmd(seed_url, seed_path, level)
    add_line("#{seed_url} #{seed_path} #{LEVEL_PARAM} #{level}")
  end

  def sort(result)
    result.sort_by_level
    result.sort_by_retailer
  end
end