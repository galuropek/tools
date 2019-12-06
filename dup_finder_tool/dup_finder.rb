$LOAD_PATH << __dir__
require 'helper'

class DupFinder

  include Utils

  def initialize(argv)
    @commands = parse_args(argv)
  end

  def run
    result = find_dup(@commands)
    # print_dup_result(result)
    # print_fast_result(result)
  end
end

DupFinder.new(ARGV).run


# result = find_dup(commands)
# print_dup_result(result)


# ARGS structure
#
# puts commands[:col][:col1].inspect
# puts commands[:col][:col2].inspect
# puts commands[:file_path].inspect