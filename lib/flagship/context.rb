class Flagship::Context
  def initialize
    @values = {}
  end

  def __set(key, value)
    @values[key.to_sym] = value
  end

  def method_missing(name, args = [], &block)
    if @values.key?(name)
      values[name]
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    @values.key?(name) or super
  end
end
