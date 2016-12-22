class Flagship::Features < Array
  def tagged_any(tags)
    Flagship::Features.new(select{|feature| tags.any?{|tag, val| feature.tags[tag] == val}})
  end

  def tagged(tags)
    Flagship::Features.new(select{|feature| tags.all?{|tag, val| feature.tags[tag] == val}})
  end

  alias tagged_all tagged

  def enabled
    Flagship::Features.new(select(&:enabled?))
  end

  def disabled
    Flagship::Features.new(select(&:disabled?))
  end
end
