require_relative 'prepare_utils'
include Utils

file_path = ARGV.first
attr_name = ARGV.count == 2 ? ARGV.last : nil
table = Utils.get_table_csv(file_path)
Utils.create_result_file(table, file_path, attr_name)