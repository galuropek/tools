require 'csv'

module FileManager

  def get_table_from_csv(path, col_sep = nil)
    CSV.parse(File.read(path), headers: true, col_sep: col_sep || "\t")
  end

  def write_to_file(file_path, text, mode = "w")
    out_path = file_path.gsub(/\.\w+$/, '_result.txt')
    file = File.open(out_path, mode)
    file.write(text)
    file.close
    puts "See result in:
#{out_path}"
  end
end