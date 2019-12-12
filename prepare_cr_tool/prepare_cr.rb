# $LOAD_PATH << __dir__
require_relative 'prepare_cr_utils'
require_relative '../modules/params'

class PrepareCR
  include Utils
  include ParamsParser

  PARAMS_SETTINGS = {
      file_path: [1, true],
      mode: [1, true],
      br_sep: [1, true],
      options: [2, false],
      col_sep: [1, false]
  }

  def initialize(argv)
    argv_params = get_params(argv, PARAMS_SETTINGS)

    # may be only one param, so: argv_params[param_name].first
    # required
    @file_path = argv_params['file_path'].first if argv_params['file_path']
    @mode = argv_params['mode'].first if argv_params['mode']
    @br_sep = argv_params['br_sep'].first if argv_params['br_sep']

    # optional
    @col_sep = argv_params['col_sep'].first if argv_params['col_sep']

    # may by some params, so will be parsed latter
    @options = argv_params['options'] || []
  end

  def run
    table = get_table_csv(@file_path, @col_sep)
    parsed_table = parse_table(table)
    hash_result = get_hash_result(parsed_table, @br_sep)

    # return Array<ResultCR>: [ResultCR, ResultCR..., ResultCR]
    result = prepare_result(hash_result)
    @options.each { |action| do_action(action, result) }
  end

  def do_action(action, result)
    case action
    when 'print'
      print_result(result, @mode)
    when 'file'
      # write_result(result, @mode)
    else
      print_message("Incorrect option: '#{action}'.")
    end
  end
end

PrepareCR.new(ARGV).run
