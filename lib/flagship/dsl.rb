class Flagship::Dsl
  class InvalidOptionError < ::StandardError; end

  attr_reader :flagset

  def initialize(key, context, base = nil, &block)
    @key = key
    @context = context
    @base = base
    @features = {}
    @definition = block
    @base_tags = {}

    instance_eval(&@definition)

    @flagset = ::Flagship::Flagset.new(@key, @features, @base)
  end

  def enable(key, opts = {})
    tags = opts.dup
    condition = tags.delete(:if)

    if condition
      @features[key] = ::Flagship::Feature.new(key, condition, @context, @base_tags.merge(tags))
    else
      @features[key] = ::Flagship::Feature.new(key, true, @context, @base_tags.merge(tags))
    end
  end

  def disable(key, opts = {})
    raise InvalidOptionError.new("Option :if is not available for #disable") if opts[:if]

    tags = opts.dup
    @features[key] = ::Flagship::Feature.new(key, false, @context, @base_tags.merge(tags))
  end

  def with_tags(tags, &block)
    orig_base_tags = @base_tags
    @base_tags = @base_tags.merge(tags)
    instance_eval(&block)
  ensure
    @base_tags = orig_base_tags
  end

  def enabled?(key)
    @flagset.enabled?(key)
  end
end
