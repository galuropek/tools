require_relative '../modules/params'
require_relative '../modules/file_manager'
require_relative 'entities/result'
require_relative 'entities/main_result'
require_relative 'entities/category_result'
require_relative 'utils/utils_cr'

class ToolCR
  include ParamsParser
  include FileManager
  include UtilsCR

  # [params_count, required?]
  PARAMS_SETTINGS = {
      file_path: [1, true],
      mode: [1, true],
      br_sep: [1, true],
      options: [2, false],
      col_sep: [1, false]
  }

  def initialize(argv)
    argv_params = get_params(argv, PARAMS_SETTINGS)

    # required
    # may be only one param, so: argv_params[param_name].first
    @file_path = argv_params['file_path'].first if argv_params['file_path']
    @mode = argv_params['mode'].first if argv_params['mode']
    @br_sep = argv_params['br_sep'].first if argv_params['br_sep']

    # optional
    @col_sep = argv_params['col_sep'].first if argv_params['col_sep']
    # may by some params, so will be parsed latter
    @options = argv_params['options'] || []
  end

  def run
    table = get_table_from_csv(@file_path)
    validate_table(table, @col_sep, %w(cat url))
    @result = Result.create(:main)
    parse_table_for_result(table)
    do_action(@options.first)
  end

  def parse_table_for_result(table)
    table.each do |element|
      category = Result.create(:category)
      category.breadcrumb = element['cat']
      category.url = element['url']
      category.retailer = element['retailer']
      category.br_sep = @br_sep
      category.calc_level
      @result.add_to_result(category)
    end
  end

  def do_action(action)
    case action
    when 'print'
      puts "Option: #{action} - not work yet >:.( Has been used option 'file' by default."
      do_action('file')
      # todo
    when 'file'
      write_result(@result, @mode, @file_path)
    else
      puts "Incorrect option '#{action}', check read.me file. Has been used option 'file' by default."
      write_result(@result, @mode, @file_path)
    end
  end
end

t = ToolCR.new(ARGV).run
