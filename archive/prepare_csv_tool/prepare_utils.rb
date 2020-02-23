require 'csv'
module Utils

  def get_table_csv(path, col_sep = nil)
    CSV.parse(File.read(path), :headers => true, :col_sep => col_sep ? col_sep : "\t")
  end

  def create_result_file(table, file_path, attr_name = nil)
    if attr_name
      create_result_file_with_headers(table, file_path, attr_name)
      return
    end
    hash = parse_table(table)
    file_name = file_path[/([\d\w\_]+)\.csv$/, 1] || '' rescue ''
    o_file = File.open("C:\\Users\\user\\Documents\\test\\#{file_name}_result.csv", "w")
    hash.keys.each do |key|
      o_file.write("\"#{key}\"\t")
      attributes = hash[key]
      attributes.each do |attr|
        o_file.write("\"#{attr}\"\t")
      end
      o_file.write("\n")
    end
    o_file.close
  end

  def create_result_file_with_headers(table, file_path, attr_name)
    hash = parse_table(table)
    keys = hash.keys
    file_name = file_path[/([\d\w\_]+)\.csv$/, 1] || '' rescue ''
    # @todo
    # change directory form static to dynamic
    File.open("C:\\Users\\user\\Documents\\test\\#{file_name}_result.csv", 'a+') do |hdr|
      res_hdr = create_headers_row(hash, table.headers.first, attr_name)
      puts res_hdr
      hdr << res_hdr if hdr.tell == 0 # file is empty, so write header
      keys.each do |key|
        hdr << "\"#{key}\""
        attributes = hash[key]
        attributes.each do |attr|
          hdr << "\t\"#{attr}\""
        end
        hdr << "\n"
      end
    end
  end

  def create_headers_row(hash, key, attr_name)
    max_columns_count = max_by_key(hash)
    puts max_columns_count
    res_hdr = "\"#{key}\""
    (1..max_columns_count).each { |i|
      res_hdr += "\t\"#{attr_name}_#{i}\""
    }
    res_hdr += "\n"
  end

  def parse_table(table)
    hash = {}
    table.each do |el|
      key = el[table.headers.first]
      attribute = el[table.headers.last]
      hash[key] = [] if hash[key].nil?
      urls = hash[key].select { |u| u == attribute }
      hash[key] << attribute if urls.empty?
    end
    hash
  end

  def max_by_key(hash)
    max = 0
    hash.keys.each do |key|
      attrs = hash[key]
      max = attrs.count if attrs.count > max
    end
    max
  end
end