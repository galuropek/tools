require 'csv'

module FileManager

  # @param [String] path - path to file
  # @param [String] col_sep in csv file
  def get_table_from_csv(path, col_sep = nil)
    CSV.parse(File.read(path), headers: true, col_sep: col_sep || "\t")
  end

  # @param [File] table
  # @param [Array] columns
  def validate_table(table, col_sep, columns)
    columns.each do |column|
      value = table.first[column]
      raise "Check '--col_sep #{col_sep}' param. Input file not parsed. By default used: \\t ." unless value
    end
  end

  # @param [String] file_path - path to file
  # @param [String] text - text to output file
  def write_to_file(file_path, text, mode = "w")
    out_path = file_path.gsub(/\.\w+$/, '_result.txt')
    file = File.open(file_path, mode)
    file.write(text)
    close_file(file)
    puts "See result in:
#{out_path}"
  end

  # @param [String] path - path to file
  def open_file(path, mode = "r")
    File.open(path, mode)
  end

  # @param [File] file
  def close_file(file)
    file.close
  end
end