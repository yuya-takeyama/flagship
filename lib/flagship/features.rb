class Flagship::Features < Array
  def tagged_any(tags)
    self.class.new(select{|feature| tags.any?{|tag, val| feature.tags[tag] == val}})
  end

  def tagged(tags)
    self.class.new(select{|feature| tags.all?{|tag, val| feature.tags[tag] == val}})
  end

  alias tagged_all tagged

  def enabled
    self.class.new(select(&:enabled?))
  end

  def disabled
    self.class.new(select(&:disabled?))
  end
end
