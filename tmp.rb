require_relative 'config'
require 'json'

class TMP

	def get_all_categories(configs)
		sections = []
		categories = []
		configs.each { |conf| sections += conf.sections }
		if sections.any?
			sections.each { |section| categories.merge(section.categories) }
		else
			puts "Sections are empty: #{sections}"
		end
		categories
	end
end

FILE_PATH = "T:\\Ruby\\tools\\test_files\\test.txt"

file = File.open(FILE_PATH, "r")

json = JSON.parse(file.read)

file.close

configs = []

json.each do |name, sections|
	config = Config.new
	config.name = name
	config.set_sections(sections)
	configs << config
end

tmp = TMP.new
puts tmp.get_all_categories(configs).inspect