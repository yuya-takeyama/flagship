class Flagship::Feature
  attr_reader :key, :tags

  def initialize(key, enabled, context, tags = {})
    @key = key
    @enabled = enabled
    @context = context
    @tags = tags
  end

  def enabled?
    env = ENV['FLAGSHIP_' + key.to_s.upcase]

    if env
      case env.downcase
      when '1', 'true'
        return true
      when '0', 'false', ''
        return false
      end
    end

    if @enabled.respond_to?(:call)
      !!@enabled.call(@context)
    else
      !!@enabled
    end
  end

  def disabled?
    !enabled?
  end

  def extend_feature(feature)
    self.class.new(@key, @enabled, @context, feature.tags.merge(@tags))
  end
end
