$LOAD_PATH << __dir__
require 'prepare_cr_utils'

class PrepareCR

  include Utils

  def initialize(argv)
    @path = argv.first
    @breadcrumb_sep = argv[1]
    @col_sep = argv[2]
    @options = parse_options(argv)
  end

  def run
    table = get_table_csv(@path, @col_sep)
    parsed_table = parse_table(table)
    @result = get_result(parsed_table, @breadcrumb_sep)
    if @options
      @options.each { |opt| do_action(opt) }
    else
      do_action('print')
    end
  end

  def do_action(option)
    case option
    when 'print'
      print_fast_result(@result)
    when 'cmd_for_shard'
      print_cmd_for_shard(@result)
    else
      puts "Incorrect option: '#{option}'. Look read.me file."
    end
  end
end

PrepareCR.new(ARGV).run