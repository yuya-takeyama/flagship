class Flagship::Dsl
  class InvalidOptionError < ::StandardError; end

  def initialize(key, base = nil, &block)
    @key = key
    @base = base
    @flags = {}
    @definition = block
  end

  def enable(key, opts = {})
    if opts[:if]
      @flags[key] = opts[:if]
    else
      @flags[key] = true
    end
  end

  def disable(key, opts = {})
    raise InvalidOptionError.new("Option :if is not available for #disable") if opts[:if]

    @flags[key] = false
  end

  def flagset
    instance_eval(&@definition)
    ::Flagship::Flagset.new(@key, @flags, @base)
  end
end
