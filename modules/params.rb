require 'pry'

module ParamsParser

  # params_settings example
  # {parameter: [parameter_count, is_required?]
  # boolean values for marking: param is required or not
  # PARAMS_SETTINGS = {
  #     file_path: [1, true],
  #     mode: [1, true],
  #     br_sep: [1, true],
  #     col_sep: [1, false],
  #     options: [2, false]
  # }

  def get_params(argv, params_settings)
    argv_is_empty?(argv)
    @params_settings = params_settings
    params = {}
    cmd_line = argv.join(' ')
    commands = cmd_line.split('--').map(&:strip).select { |cmd| !cmd.empty? }
    commands.each do |cmd|
      validated_params = param_validator(cmd)
      next unless validated_params

      params.merge!(validated_params)
    end
    check_required_params(params)
    params
  end

  def argv_is_empty?(argv)
    raise print_message("Params is empty!") if argv.count < 1
  end

  # @param [String] cmd - line from ARGV (example: 'file_path Documents\test\CR.csv')
  # @return [Hash] when params is valid
  # {String - param_name: Array - options [String, String..., String]}
  # @return [False] when params is invalid
  def param_validator(cmd)
    params = params_from_cmd(cmd)
    param_name = params.first
    params_is_valid?(params) ? {param_name.to_sym => params.shift} : false
  end

  def params_is_valid?(params)
    param_name = params.shift
    settings_array = @params_settings[:"#{param_name}"]
    params_count_expected = settings_array ? settings_array.first : nil
    if params_count_expected
      if params.count <= params_count_expected
        true
      else
        raise print_message("Incorrect param: #{param_name}\nExpected params count: #{params_count_expected}, current params count: #{params.count}.")
      end
    else
      raise print_message("Pay attention, please! Param '--#{param_name}' not support.")
    end
  end

  def check_required_params(params)
    get_required_params.each do |req_param|
      raise print_message("Required param '--#{req_param}' is not present.") unless params[req_param]
    end
  end

  def get_required_params
    required_params = []
    @params_settings.each { |key, value| required_params << key.to_sym if value.last }
    required_params
  end

  ##### Helpers
  def params_from_cmd(cmd)
    params = cmd.split(' ')
    params.count > 1 ? params : print_message("Incorrect param: #{cmd}. Present only param name without action.")
  end

  def print_message(message)
    puts "#{message} Look read.me file for help."
  end
end

