class MainResult < Result

  def initialize
    @result_array = []
  end

  # @param [CategoryResult] result
  def add_to_result(result)
    @result_array << result
  end

  # @return [Array]
  def get_all
    @result_array
  end

  def count
    @result_array.count
  end

  def sort_by_retailer
    @result_array.sort_by! { |result| result.retailer }
  end

  def sort_by_level
    @result_array.sort_by! { |result| result.level }
  end

  def print
    @result_array.each { |result| puts result.to_string }
  end
end