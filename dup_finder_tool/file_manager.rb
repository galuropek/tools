require 'csv'

module FileManager

  # Files content
  #
  def get_table_csv(path, col_sep = "\t")
    CSV.parse(File.read(path), :headers => true, :col_sep => col_sep)
  end
end