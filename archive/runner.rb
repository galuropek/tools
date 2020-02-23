require_relative 'entities/tities/result'
require_relative 'entities/category_result'
require_relative 'entities/main_result'
require_relative '../modules/file_manager'

FILE_PATH = '/home/hlaushka/Documents/docs/file.csv'

br = 'Hello *** world *** !!!'
url = 'oz.by/books/'
retailer = 'OZ'
br_sep = '>>>'

result = Result.create(:main)

FileManager.get_table_from_csv(FILE_PATH).each do |element|
  category = Result.create(:category)
  category.breadcrumb = element['cat']
  category.url = element['url']
  category.retailer = element['retailer']
  # category.br_sep = br_sep
  category.calc_level
  result.add_to_result(category)
end

result.print

puts __dir__
