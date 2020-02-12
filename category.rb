class Category
	attr_accessor :category_name, :url, :retailer

	def initialize(category, url, retailer)
		@category_name = category
		@url = url
		@retailer = retailer
	end
end