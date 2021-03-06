require_relative '../../modules/file_manager'
require_relative '../entities/result'
require_relative '../entities/main_result'
require_relative '../entities/category_result'

require 'colorize'
require 'json'
require 'pry'

module UtilsCR
  include FileManager

  SEED_URL_PARAM = '--seed_url'
  SEED_PATH_PARAM = '--seed_path'
  LEVEL_PARAM = '--level'
  LINE_BREAK = "\n"
  COMMA_SEP = ','
  RETAILER = '###RETAILER'
  LEVEL = '///level'

  # @param [MainResult] result
  # @param [String] mode
  # @param [String] file_path
  def write_result(result, mode, file_path)
    str_result = get_str_result(result, mode)
    write_to_file(file_path, str_result)
  end

  # @param [MainResult] result
  # @param [String] mode
  def print_result(result, mode)
    puts get_str_result(result, mode)
  end

  def get_str_result(result, mode)
    config_path = '/home/hlaushka/Documents/docs/config.txt'
    case mode
    when 'job'
      job_format(result)
    when 'cmd'
      cmd_format(result)
    when 'compare'
      config_result = parse_rr_job(config_path)
      compare_format(config_result, result)
    else
      "PAY ATTENTION!!! Incorrect mode: #{mode.inspect}. Check your command '--mode' and read.me file."
    end
  end

  ##### COMPARING CR WITH RR-JOB

  # @param [String] file_path - file to path
  # @return [MainResult]
  def parse_rr_job(file_path)
    result = Result.create(:main)
    file = open_file(file_path)
    config = JSON.parse(file.read)
    unless config['Crawling']
      puts "'Crawling' section not found into rr-job."
      return
    end
    config['Crawling'].each do |section|
      parse_section(section, result)
    end
    result
  end

  def parse_section(section, result)
    unless section['categories']
      puts "'categories' not found into section #{section['name']}."
      return
    end
    section['categories'].each do |category, url|
      category_result = Result.create(:category)
      category_result.breadcrumb = category
      category_result.url = url
      result.add_to_result(category_result)
    end
  end

  def compare_format(config_result, cr_result)
    config_result
    puts "Not working yet :("
    #todo
  end

  ##### PREPARE CR FOR JOB/CMD

  # @param [Table] table
  # @return [MainResult]
  def parse_table_for_result(table, br_sep)
    result = Result.create(:main)
    table.each do |element|
      category = Result.create(:category)
      category.breadcrumb = element['cat']
      category.url = element['url']
      category.retailer = element['retailer']
      category.br_sep = br_sep
      category.calc_level
      result.add_to_result(category)
    end
    result
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
    group.each do |retailer, cats|
      add_retailer(retailer)
      group_by(cats, 'level').each do |level, cats_array|
        need_to_add_level = true
        cats_array.each_with_index do |category, index|
          if need_to_add_level
            add_level(level)
            need_to_add_level = false
          end
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
        need_to_add_level = true
        cats_array.each_with_index do |category, index|
          if need_to_add_level
            add_level(level)
            need_to_add_level = false
          end
          seed_url += " \"#{category.url.strip}\""
          seed_path += " \"#{category.breadcrumb.strip}\""
        end
        add_cmd(seed_url, seed_path, level)
      end
      add_line(LINE_BREAK)
    end
    @str_result
  end

  def check_url_duplicates(result)
    duplicates_by_url = {}
    by_url = result.sort_by_url

    by_url.each_with_index do |category, index|
      if index != by_url.count - 1
        next_category = by_url[index + 1]
          if category.url.eql?(next_category.url)
            duplicates_by_url[category.url] = [] unless duplicates_by_url[category.url]
            [category, next_category].each { |category| add_if_not_present(duplicates_by_url[category.url], category) }
          end
      end
    end

    print_url_duplicates(duplicates_by_url) unless duplicates_by_url.empty?
  end

  def print_url_duplicates(duplicates_by_url)
    print_limit = 2
    puts "PAY ATTENTION, PLEASE!!!\nFound duplicates by url:"

    duplicates_by_url.each do |category_url, categories|
      puts "\tcount: #{categories.count}, url: #{category_url}"

      categories.each_with_index { |category, index|
        if index > print_limit
          puts "\t\t..."

          break
        end

        puts "\t\tbreadcrumb: #{category.breadcrumb}"
      }
    end
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
    add_line("#{LEVEL}: #{category_level}")
  end

  def add_retailer(retailer)
    add_line("#{RETAILER}: #{retailer}")
  end


  def add_cmd(seed_url, seed_path, level)
    add_line("#{seed_url} #{seed_path} #{LEVEL_PARAM} #{level}")
  end

  def sort(result)
    result.sort_by_level
    result.sort_by_retailer
  end

  def add_if_not_present(cats, category)
    cats << category unless cats.find { |cat| cat == category }
  end
end