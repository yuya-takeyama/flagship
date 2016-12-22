class Flagship::Features < Array
  def tagged(tags)
    Flagship::Features.new(select{|feature| tags.any?{|tag, val| feature.tags[tag] == val}})
  end

  def tagged_all(tags)
    Flagship::Features.new(select{|feature| tags.all?{|tag, val| feature.tags[tag] == val}})
  end

  def enabled
    Flagship::Features.new(select(&:enabled?))
  end

  def disabled
    Flagship::Features.new(select(&:disabled?))
  end
end
