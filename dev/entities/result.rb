class Result

  def self.type_list
    {
        :main => MainResult,
        :category => CategoryResult
    }
  end

  def self.create(type)
    type_list[type].new
  end

  def to_string
    #todo
  end

  def print
    #todo
  end
end