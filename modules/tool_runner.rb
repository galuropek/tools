module ToolRunner
  TOOLS_PATH = '../dev/tools/'

  class ToolCreator
    def create(tool)
      require_tool(tool)
      Object.const_get(tool_to_class(tool)).new(menu_dialog: true)
    end

    private

    def require_tool(tool)
      require_relative TOOLS_PATH + tool
    end

    def tool_to_class(tool)
      tool.split('_').map(&:capitalize).join
    end

    def validate_tool
      # todo
      raise "not implemented"
    end
  end

  def create_tool(tool)
    ToolCreator.new.create(tool)
  end
end