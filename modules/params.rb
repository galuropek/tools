module ParamsParser

  # boolean values for marking: param is required or not
  @@params = {
      file_path: [1, true],
      mode: [1, true],
      br_sep: [1, true],
      col_sep: [1, false],
      options: [2, false]
  }

  def get_params(argv)
    argv_is_empty?(argv)
    params = {}
    cmd_line = argv.join(' ')
    commands = cmd_line.split('--').map(&:strip).select { |cmd| !cmd.empty? }
    commands.each do |cmd|
      # recognize_command(cmd.split(' '), result)
      validated_params = param_validator(cmd)
      next unless validated_params

      params.merge!(validated_params)
    end
    check_required_params(params)
    params
  end

  def argv_is_empty?(argv)
    raise print_message('Params is empty!') if argv.count < 1
  end

  # @param [String] cmd - line from ARGV (example: 'file_path Documents\test\CR.csv')
  # @return [Hash] when params is valid
  # {String - param_name: Array - options [String, String..., String]}
  # @return [False] when params is invalid
  def param_validator(cmd)
    params = params_from_cmd(cmd)
    param_name = params.first
    if params_is_valid?(params)
      {param_name => params}
    else
      false
    end
  end

  def params_is_valid?(params)
    params_count_expected = @@params[:"#{params.shift}"].first
    if params_count_expected
      params.count == params_count_expected
    else
      print_message("Params count more then #{params_count_expected}.")
      false
    end
  end

  def check_required_params(params)
    get_required_params.each do |req_param|
      raise print_message("Required param '--#{req_param}' is not present.") unless params[req_param]
    end
  end

  def get_required_params
    required_params = []
    @@params.each { |key, value| required_params << key.to_s if value.last }
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
