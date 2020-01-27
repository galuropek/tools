require_relative 'result_cr'
require_relative '../modules/file_manager'
require 'csv'

module Utils

  include FileManager

  SEED_URL_PARAM = '--seed_url'
  SEED_PATH_PARAM = '--seed_path'
  LEVEL_PARAM = '--level'

  # @param [String] path - path to input csv file
  # @param [String] col_sep - column separator in csv file
  def parse_input_file(path, col_sep)
    hash = {}
    table = get_table_from_csv(path, col_sep)
    parse_table(table, hash)
    hash
  end

  def parse_table(table, hash)
    table.each do |el|
      key = el['cat']
      attribute = el['url']
      hash[key] = {} unless hash[key]
      hash[key][:attr] = attribute
      hash[key][:retailer] = el['retailer']
    end
    hash
  end

  def get_hash_result(hash, breadcrumb_sep)
    result = {}
    if hash.count == 1
      raise "\nFile has not been parsed. Check col_sep or column names!"
    end

    hash.keys.each do |key|
      breadcrumb = breadcrumb_formatter(key, breadcrumb_sep)
      level = breadcrumb.split('***').count
      retailer = hash[key][:retailer] || 'no_retailer'
      result[retailer] = {} unless result[retailer]
      result[retailer][level] = [] unless result[retailer][level]
      result[retailer][level] << "\"#{breadcrumb}\": \"#{hash[key][:attr]}\""
    end
    result
  end

  def breadcrumb_formatter(key, breadcrumb_sep)
    cats = key.split(breadcrumb_sep)
    cats.map!(&:strip).join(' *** ')
  end

  def print_fast_result(result)
    result.keys.each do |retailer|
      puts retailer
      result[retailer].each { |cr| puts cr }
      puts "=============================\n\n"
    end
  end

  def print_cmd_for_shard(result)
    result.keys.each do |key|
      puts key
      cr_by_levels = result[key]
      levels = cr_by_levels.keys
      levels.each do |lvl|
        parse_breadcrumb_for_cmd(cr_by_levels[lvl], 'print')
        puts "#{LEVEL_PARAM} " + lvl.to_s
      end
    end
  end

  def parse_breadcrumb_for_cmd(cr_array, action, file = nil)
    breadcrumbs = []
    urls = []
    cr_array.each do |breadcrumb|
      cr_after_split = breadcrumb.split(': ')
      breadcrumbs << cr_after_split.first
      urls << cr_after_split.last
    end
    case action
    when 'print'
      print "#{SEED_URL_PARAM} "
      urls.each { |url| print url + ' ' }
      print "#{SEED_PATH_PARAM} "
      breadcrumbs.each { |b| print b + ' ' }
    when 'file'
      if file
        file.write("#{SEED_URL_PARAM} ")
        urls.each { |url| file.write url + ' ' }
        file.write("#{SEED_PATH_PARAM} ")
        breadcrumbs.each { |b| file.write b + ' ' }
      else
        puts 'Problem with output-file.'
      end
    else
      puts 'Unknown action.'
    end
  end

  def prepare_result(parsed_result)
    cr_array = []
    parsed_result.each do |key, value|
      levels_array = value.keys
      add_result(cr_array, levels_array, value, key)
    end
    cr_array
  end

  def add_result(cr_array, levels_array, values_array, retailer)
    cr = ResultCR.new
    cr.retailer = retailer
    cr.levels = levels_array
    cr.cats = values_array
    cr_array << cr
  end

  def print_result(result, mode)
    case mode
    when 'for_job'
      print_result_for_job(result)
    when 'for_shard'
      print_result_for_shard(result)
    else
      puts "Incorrect mode: #{mode}. Look read.me file."
    end
  end

  def print_result_for_job(result)
    result.each do |cr|
      puts cr.retailer
      cr.levels.each do |lvl|
        puts "level: #{lvl}"
        puts cr.cats[lvl]
      end
      puts
    end
  end

  def print_result_for_shard(result)
    result.each do |cr|
      puts cr.retailer
      cr.levels.each do |lvl|
        parse_breadcrumb_for_cmd(cr.cats[lvl], 'print')
        puts "#{LEVEL_PARAM} #{lvl}"
      end
      puts
    end
  end

  def write_result(result, mode, file_path)
    case mode
    when 'for_job'
      write_result_for_job(result, file_path)
    when 'for_shard'
      write_result_for_shard(result, file_path)
    else
      puts "Incorrect mode: #{mode}. Look read.me file."
    end
  end

  def write_result_for_job(result, file_path)
    file = File.open(file_path.gsub('.csv', '_result.txt'), "w")
    result.each do |cr|
      file.write("#{cr.retailer}\n")
      cr.levels.each do |lvl|
        file.write("level: #{lvl}\n")
        # file.write("#{cr.cats[lvl]}\n")
        cr.cats[lvl].each_with_index { |cat, index|
          file.write("#{cat}")
          file.write(",") if index < cr.cats[lvl].count - 1
          file.write("\n")
        }
      end
      file.write("\n")
    end
  end

  def write_result_for_shard(result, file_path)
    file = File.open(file_path.gsub('.csv', '_result.txt'), "w")
    result.each do |cr|
      file.write("#{cr.retailer}\n")
      cr.levels.each do |lvl|
        parse_breadcrumb_for_cmd(cr.cats[lvl], 'file', file)
        file.write("#{LEVEL_PARAM} #{lvl}")
      end
      file.write("\n")
    end
  end
end
