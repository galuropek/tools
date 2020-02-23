class Category
	attr_accessor :category_name, :url, :retailer, :level

	def initialize(category, url, retailer = nil)
		@category_name = category
		@url = url
		@retailer = retailer
	end
end