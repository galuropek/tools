require_relative '../../modules/params'

require 'pry'

class BaseTool
  include ParamsParser

  NOT_IMPLEMENT = "Not implement".freeze
  PARAMS_SETTINGS = {}
  DIALOG = {}

  def initialize(argv: nil, menu_dialog: false, params_settings: PARAMS_SETTINGS, dialog: DIALOG)
    if argv && !menu_dialog
      @params = get_params(argv, params_settings)
    elsif !argv && menu_dialog
      if dialog.empty?
        raise "Empty DIALOG: #{DIALOG} in dialog mode"
      else
        @params = nil
        @dialog = dialog
      end
    else
      raise "Incorrect init arguments"
    end
  end

  def run
    dialog_params unless @params
    custom_logic
    do_action
  end

  private

  def dialog_params
    @params = {}

    @dialog.each do |param, values|
      prepare_dialog_values(values).each { |msg| puts msg }
      @params[ param.to_sym ] = gets.chomp
    end

    # fast start
    # @params =
    #     {
    #         file_path: "/home/hlaushka/Documents/docs/file.csv",
    #         mode: "cmd",
    #         br_sep: "***",
    #         option: "print"
    #     }
  end

  def custom_logic
    raise NOT_IMPLEMENT
  end

  def do_action
    raise NOT_IMPLEMENT
  end

  def prepare_dialog_values(values)
    phrase = values[:phrase]
    example = values[:example] ? "\texample: #{ values[:example] }".yellow : nil

    [phrase, example].compact
  end
end