class Flagship::Dsl
  class InvalidOptionError < ::StandardError; end

  def initialize(key, &block)
    @key = key
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
    ::Flagship::Flagset.new(@key, @flags)
  end
end
