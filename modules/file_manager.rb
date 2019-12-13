require 'csv'

module FileManager

  def get_table_csv(path, col_sep)
    CSV.parse(File.read(path), headers: true, col_sep: col_sep || "\t")
  end
end