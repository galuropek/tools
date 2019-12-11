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
      options: [2, true],
      col_sep: [1, false]
  }

  def initialize(argv)
    argv_params = get_params(argv, PARAMS_SETTINGS)

    # may be only one param, so: argv_params[param_name].first
    # required
    @file_path   = argv_params['file_path'].first if argv_params['file_path']
    @mode        = argv_params['mode'].first if argv_params['mode']
    @br_sep      = argv_params['br_sep'].first if argv_params['br_sep']

    # may by some params, so will be parsed latter
    # required
    @options     = argv_params['options']

    # optional
    @col_sep     = argv_params['col_sep'].first if argv_params['col_sep']
  end

  def run
    table = get_table_csv(@file_path, @col_sep)
    parsed_table = parse_table(table)
    @result = get_result(parsed_table, @br_sep)
    puts @result
    # if @options
    #   @options.each { |opt| do_action(opt) }
    # else
    #   do_action('print')
    # end
  end

  def do_action(option)
    case option
    when 'print'
      print_fast_result(@result)
      print_cmd_for_shard(@result)
    when 'for_job'

    when 'for_shard'
      # print_cmd_for_shard(@result)
    when 'result_in_file'
    else
      puts "Incorrect option: '#{option}'. Look read.me file."
    end
  end
end

PrepareCR.new(ARGV).run
