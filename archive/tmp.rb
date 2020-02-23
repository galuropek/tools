require_relative 'config'
require_relative 'category'
require_relative 'modules/es/file_manager'
require 'json'

class TMP

	include FileManager

	def get_all_categories(configs)
		sections = []
		categories = []
		configs.each { |conf| sections += conf.sections }
		if sections.any?
			# sections.each { |section| categories + section.categories }
			puts sections.inspect
		else
			puts "Sections are empty: #{sections}"
		end
		categories
	end

	def parse_input_file(path, col_sep)
	    table = get_table_from_csv(path, col_sep)
	    parse_table(table)
	end

	def parse_table(table)
		categories_array = []
		table.each do |element|
			categories_array << Category.new(
				element['cat'],
				element['url'],
				element['retailer']
			)
		end
		categories_array
	end

	# Return hash: {retailer => [category1, category2...]}
	def sort_by_retailers(categories)
		hash_by_retailers = {}
		categories.each do |category|
			retailer = category.retailer
			hash_by_retailers[retailer] = [] if hash_by_retailers[retailer].nil?
			hash_by_retailers[retailer] << category
		end
		hash_by_retailers
	end
end

# FILE_PATH = "T:\\Ruby\\tools\\test_files\\test.txt"

# file = File.open(FILE_PATH, "r")

# json = JSON.parse(file.read)

# file.close

# configs = []

# json.each do |name, sections|
# 	config = Config.new
# 	config.name = name
# 	config.set_sections(sections)
# 	configs << config
# end

# tmp = TMP.new
# puts tmp.get_all_categories(configs).inspect
##########################################################

# FILE_PATH = "T:\\Ruby\\tools\\test_files\\file.csv"

# tmp = TMP.new
# arr = tmp.parse_input_file(FILE_PATH, "\t")

# sorted_by_retailer = tmp.sort_by_retailers(arr)
