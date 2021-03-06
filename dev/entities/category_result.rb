require 'colorize'

class CategoryResult < Result
  attr_accessor :breadcrumb, :url, :retailer, :level, :br_sep, :parsed_breadcrumb

  def initialize
    @br_sep = '***'
  end

  def calc_level
    @level = do_parse_br.count
  end

  def to_string
    "Breadcrumb: #{@breadcrumb}, url: #{@url}, retailer: #{@retailer}, level: #{@level}"
  end

  def get(key)
    instance_variable_get("@#{key}")
  end

  def parse_breadcrumb
    @parsed_breadcrumb = do_parse_br
  end

  def do_parse_br
    @breadcrumb.split(@br_sep).map(&:strip)
  end
end