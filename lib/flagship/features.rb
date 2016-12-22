class Flagship::Features < Array
  def tagged(tags)
    Flagship::Features.new(self.select{|feature| tags.any?{|tag, val| feature.tags[tag] == val}})
  end

  def tagged_all(tags)
    Flagship::Features.new(self.select{|feature| tags.all?{|tag, val| feature.tags[tag] == val}})
  end

  def enabled
    Flagship::Features.new(self.select{|feature| feature.enabled?})
  end

  def disabled
    Flagship::Features.new(self.select{|feature| feature.disabled?})
  end
end
