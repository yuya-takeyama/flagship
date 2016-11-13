class Flagship::Dsl
  class InvalidOptionError < ::StandardError; end

  def initialize(key, context, base = nil, &block)
    @key = key
    @context = context
    @base = base
    @features = {}
    @definition = block
  end

  def enable(key, opts = {})
    opts = opts.dup
    condition = opts.delete(:if)

    if condition
      @features[key] = ::Flagship::Feature.new(key, condition, @context, opts)
    else
      @features[key] = ::Flagship::Feature.new(key, true, @context, opts)
    end
  end

  def disable(key, opts = {})
    raise InvalidOptionError.new("Option :if is not available for #disable") if opts[:if]

    @features[key] = ::Flagship::Feature.new(key, false, @context, opts)
  end

  def flagset
    instance_eval(&@definition)
    ::Flagship::Flagset.new(@key, @features, @base)
  end
end
