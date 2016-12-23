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

    if @base
      @base.helper_methods.each do |method|
        define_singleton_method(method.name, &method)
      end
    end

    instance_eval(&@definition)

    helper_methods = singleton_methods.map { |sym| method(sym) }
    @flagset = ::Flagship::Flagset.new(@key, @features, @base, helper_methods)
  end

  def enable(key, opts = {})
    tags = opts.dup
    condition = tags.delete(:if)
    condition = method(condition) if condition.is_a?(Symbol) # convert to proc

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

  def disabled?(key)
    @flagset.disabled?(key)
  end

  def include(mod)
    extend mod
  end
end
