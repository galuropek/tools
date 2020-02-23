class CategoryResult < Result
  attr_accessor :breadcrumb, :url, :retailer, :level, :br_sep

  def initialize
    @br_sep = '***'
  end

  def calc_level
    @level = @breadcrumb.split(@br_sep).count
  end

  def to_string
    "Breadcrumb: #{@breadcrumb}, url: #{@url}, retailer: #{@retailer}, level: #{@level}"
  end

  def get(key)
    instance_variable_get("@#{key}")
  end
end