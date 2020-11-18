require_relative 'modules/tool_runner'

require 'colorize'

class Launcher
  include ToolRunner

  TOOLS_PATH = 'dev/tools'
  README_PATH = 'dev/readme'
  STEP_TWO = {
      1 => "continue",
      2 => "back"
  }

  def initialize
    @step = :main_menu
  end

  def run
    tool_index = -1

    # step one
    while @step == :main_menu
      init_tools_list
      print_tools_list
      tool_index = gets.chomp.to_i - 1 rescue -1
      validate_tool_index(tool_index) ? @step = :step_two : next
      print_tool_info(tool_index)

      # step two
      run_step_two
    end

    # create and run found tool
    argv_params = "--file_path /home/hlaushka/Documents/docs/file.csv --mode cmd --br_sep *** --options print".split
    tool = create_tool(@tools_list[tool_index], argv_params)
    tool.run
  end

  private

  def run_step_two
    while @step == :step_two
      print_step_two_menu
      step_two = gets.chomp.to_i

      if validate_step_two_value(step_two) && STEP_TWO[step_two].downcase == "back"
        @step = :main_menu
      elsif validate_step_two_value(step_two)
        @step = nil
      else
        puts "Incorrect step number. Enter number between #{STEP_TWO.keys.first} and #{STEP_TWO.keys.last} please.".red
      end
    end
  end

  def init_tools_list
    @tools_list =
        Dir.entries(TOOLS_PATH)
            .select { |tool| tool.include?('.rb') }
            .map { |tool| tool.gsub('.rb', '') }
  end

  def print_tools_list
    puts "Select tool what you want:".blue

    @tools_list.each_with_index do |tool_name, index|
      puts "\t#{index + 1}. #{tool_name}"
    end
  end

  def print_tool_info(tool_index)
    tool_name = @tools_list[tool_index]
    info_path = README_PATH + "/#{tool_name}/info"

    puts "TOOL INFO: #{@tools_list[tool_index]}"
    begin
      puts File.read(info_path)
    rescue
      puts "No such INFO file or directory: #{info_path}".yellow
    end
  end

  def print_step_two_menu
    #todo
    puts "Select what you want to do next:".blue

    STEP_TWO.each do |key, value|
      puts "\t#{key}. #{value}"
    end
  end

  # def create_tool(tool:)
  #   #todo params
  #   argv_params = "--file_path /home/hlaushka/Documents/docs/file.csv --mode cmd --br_sep *** --options print".split
  #   ToolsRunner.create(tool, argv_params)
  # end

  def validate_tool_index(tool_index)
    if tool_index < 0 || tool_index > @tools_list.count - 1
      puts "Incorrect tool number. Entered tool number should be between 1 and #{@tools_list.count}.".red
      false
    else
      true
    end
  end

  def validate_step_two_value(step_two)
    STEP_TWO.keys.find { |key| key == step_two } ? true : false
  end
end

Launcher.new.run