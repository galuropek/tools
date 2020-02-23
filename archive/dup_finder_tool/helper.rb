require_relative 'file_manager'
include FileManager

module Utils

  # Parsing args for extracting needed commands
  # return hash {:col=>{:col1=>"", :col2=>""}, :file_path=>"", :out_path=>""}
  def parse_args(args)
    result = {}
    cmd_line = args.join(' ')
    commands = cmd_line.split('--').select { |cmd| !cmd.strip.empty? }
    commands.each do |cmd|
      recognize_command(cmd.split(' '), result)
    end
    result
  end

  def recognize_command(cmd_arr, result)
    case cmd_arr.first
    when 'col'
      get_col(cmd_arr, result)
    when 'file_path'
      get_file_path(cmd_arr, result)
    when 'out_path'
      get_file_path(cmd_arr, result, 'write')
    else
      puts "No one param was enter!"
    end
  end

  def get_col(cmd_arr, result)
    cols = {}
    cmd_count = cmd_arr.count - 1
    cmd_count = 2 if cmd_count > 2
    puts "Need any col name for --col param!" if cmd_count == 0
    (1..cmd_count).each { |i|
      cols[:col1] = cmd_arr[i] if i == 1
      cols[:col2] = cmd_arr[i] if i == 2
    }
    result[:col] = cols.empty? ? nil : cols
  end

  def get_file_path(cmd_arr, result, mode = 'open')
    cmd_count = cmd_arr.count
    if cmd_count > 1
      result[:file_path] = cmd_arr[1] if mode == 'open'
      result[:out_path] = cmd_arr[1] if mode == 'write'
    else
      puts "Enter file path!"
    end
  end

  # Finding dup in file by col value and return if found dup: col_value, dup counter, row where
  # return hash {""=>{:col=>"name", :row=>{"id"=>"1", "name"=>"Prod", "sku"=>"B97"}, :dup_counter=>2, :headers=>"id\"\t\"name\"\t\"sku\""}, "Know"=>{:col=>"name", :row=>{"id"=>"4", "name"=>"Know", "sku"=>"B021"}, :dup_counter=>5, :headers=>"id\"\t\"name\"\t\"sku\""}}
  def find_dup(commands)
    cols = commands[:col]
    path = commands[:file_path]
    out_path = commands[:out_path]
    if cols && path && !path.empty?
      table = get_table_csv(path)
      puts table.class
      if cols[:col1] && cols[:col2]
        # find_dup_by_two_col(table, cols)
        puts "Two col doesn`t work yet"
      elsif cols[:col1]
        result = find_dup_by_one_col(table, cols)
        puts out_path
        if result && out_path
          write_res_in_file(result, out_path)
          puts result
          result
        elsif result
          result
        else
          puts "Cool! Dups not found."
        end
      else
        puts "find_dup():\nNot found any cols for fining dup"
      end
    end
  end

  def find_dup_by_one_col(table, cols)
    result = {}
    col_header = cols[:col1]
    dup_table = table.dup
    table.each do |row|
      dup_counter = 0
      value = row[col_header]
      dup_table.each do |dup_row|
        dup_counter += 1 if value.eql?(dup_row[col_header])
      end
      if dup_counter > 1 && result[value].nil?
        result[value] = {
            :col => col_header,
            :row => row.to_hash,
            :dup_counter => dup_counter,
            :headers => "#{table.headers.join("\"\t\"")}\""
        }
      end
    end
    result.empty? ? nil : result
  end

  # @todo
  # need add numbers of rows from original file
  def write_res_in_file(result, out_path)
    keys = result.keys
    File.open(out_path, 'a+') do |hdr|
      res_hdr = "dup_counter\"\t\"by_col\"\t\"col_value\"\t\""
      puts "#{res_hdr}#{result.dig(keys.first, :headers)}\n" if hdr.tell == 0 # file is empty, so write header
      hdr << "\"#{res_hdr}#{result.dig(keys.first, :headers)}\n" if hdr.tell == 0 # file is empty, so write header
      keys.each do |key|
        row = result.dig(key, :row)
        col_name = result.dig(key, :col)
        dup_counter = result.dig(key, :dup_counter)
        res_values = "#{dup_counter}\"\t\"#{col_name}\"\t\"#{key}\"\t\""
        puts "\"#{res_values}#{row_formatter(row, "\"\t\"")}\"\n"
        hdr << "\"#{res_values}#{row_formatter(row, "\"\t\"")}\"\n"
      end
    end
  end

  def print_dup_result(result)
    result.keys.each do |key|
      row = row_formatter(result.dig(key, :row))
      col_name = result.dig(key, :col)
      dup_counter = result.dig(key, :dup_counter)
      puts "///\nDup_counter: #{dup_counter}\nDup_by: #{col_name} => #{key}\nOriginal_row:\n#{row}\n\n"
    end
  end

  def print_fast_result(result)
    result.keys.each { |key| puts "#{result[key][:row][result[key][:col]]} => #{result[key][:dup_counter]}" }
  end

  def row_formatter(row, col_sep = " || ")
    result = ''
    sep = ''
    row.keys.each do |key|
      unless row[key].to_s.strip.empty?
        result += "#{sep}#{row[key].strip}"
        sep = col_sep
      end
    end
    result
  end
end
