require_relative '../modules/params'
require_relative '../modules/file_manager'
require_relative '../dev/utils/utils_cr'

class ToolCheckRRJ
  include ParamsParser
  include FileManager
  include UtilsCR

  PARAMS_SETTINGS = {
      cr_path: [1, true],
      conf_path: [1, true],
      br_sep: [1, false],
      col_sep: [1, true]
  }

  def initialize(argv)
    argv_params = get_params(argv, PARAMS_SETTINGS)
    @cr_path = argv_params['cr_path'].first if argv_params['cr_path']
    @conf_path = argv_params['conf_path'].first if argv_params['conf_path']
    @br_sep = argv_params['br_sep'] ? argv_params['br_sep'].first : '***'
  end

  def run
    #todo
  end
end