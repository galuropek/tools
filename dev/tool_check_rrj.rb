class ToolCheckRRJ

  PARAMS_SETTINGS = {
      cr_path: [1, true],
      conf_path: [1, true],
  }

  def initialize(argv)
    argv_params = get_params(argv, PARAMS_SETTINGS)
    @cr_path = argv_params['cr_path'].first if argv_params['cr_path']
    @conf_path = argv_params['conf_path'].first if argv_params['conf_path']
  end

end