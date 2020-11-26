require_relative '../../modules/params'
require_relative '../../modules/file_manager'
require_relative '../entities/result'
require_relative '../entities/main_result'
require_relative '../entities/category_result'
require_relative '../utils/utils_cr'
require_relative 'base_tool'

require 'pry'

class ToolCr < BaseTool
  include FileManager
  include UtilsCR

  # [params_count, required?]
  PARAMS_SETTINGS = {
      file_path: [1, true],
      mode: [1, true],
      br_sep: [1, true],
      option: [1, false],
      col_sep: [1, false]
  }
  DIALOG = {
      file_path: {
          phrase: "enter file path to prepared csv file",
          example: "/home/hlaushka/Documents/docs/file.csv"
      },
      mode: {
          phrase: "enter mode please, one of this: job, cmd, compare",
          example: nil
      },
      br_sep: {
          phrase: "enter breadcrumb separator please",
          example: "***"
      },
      option: {
          phrase: "enter potion please, one of this: print, file",
          example: nil
      }
  }

  def initialize(argv: nil, menu_dialog: nil)
    super(argv: argv, menu_dialog: menu_dialog, params_settings: PARAMS_SETTINGS, dialog: DIALOG)
  end

  private

  def custom_logic
    table = get_table_from_csv(@params[:file_path])
    validate_table(table, @params[:col_sep], %w(cat url))
    @result = Result.create(:main)
    parse_table_for_result(table)
  end

  def do_action
    case @params[:option]
    when 'print'
      print_result(@result, @params[:mode])
    when 'file'
      write_result(@result, @params[:mode], @params[:file_path])
    else
      puts "Incorrect option '#{@params[:option]}', check read.me file. Has been used option 'file' by default."
      write_result(@result, @params[:mode], @params[:file_path])
    end

    check_url_duplicates(@result)
  end

  def parse_table_for_result(table)
    table.each do |element|
      category = Result.create(:category)
      category.breadcrumb = element['cat']
      category.url = element['url']
      category.retailer = element['retailer']
      category.br_sep = @params[:br_sep]
      category.calc_level
      @result.add_to_result(category)
    end
  end
end
