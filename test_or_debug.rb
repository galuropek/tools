# require_relative 'test_dialogue'
#
# class TestOrDebug
#
#   def initialize
#     @tmp = TestDialogue.new
#   end
#
#   def run
#     @tmp.run
#   end
#
# end
#
# test = TestOrDebug.new
# test.run
#
require_relative 'modules/file_manager'
include FileManager

path = test_path_to_test_file("ranking_file")
# file_text = read_file(path)
# puts file_text
#
puts get_table_from_csv(path, col_sep = nil).class