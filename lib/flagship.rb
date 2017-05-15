require "flagship/version"
require "flagship/context"
require "flagship/dsl"
require "flagship/feature"
require "flagship/features"
require "flagship/flagset"
require "flagship/flagsets_container"

module Flagship
  class NoFlagsetSelectedError < ::StandardError; end

  class << self
    def define(key, options = {}, &block)
      context = self.default_context
      base = options[:extend] ? self.get_flagset(options[:extend]) : nil
      default_flagsets_container.add ::Flagship::Dsl.new(key, context, base, &block).flagset
    end

    def enabled?(key)
      current_flagset.enabled?(key)
    end

    def set_context(key_or_hash, value=nil)
      if key_or_hash.is_a?(Hash)
        key_or_hash.each { |k, v| default_context.__set(k, v) }
      else
        default_context.__set(key_or_hash, value)
      end
    end

    def with_context(values, &block)
      default_context.with_values values do
        block.call
      end
    end

    def select_flagset(key)
      @current_flagset = default_flagsets_container.get(key)
    end

    def features
      current_flagset.features
    end

    def get_flagset(key)
      default_flagsets_container.get(key)
    end

    def default_flagsets_container
      @default_flagsts_container ||= ::Flagship::FlagsetsContainer.new
    end

    def current_flagset
      @current_flagset or raise NoFlagsetSelectedError.new('No flagset is selected')
    end

    def default_context
      @default_context ||= ::Flagship::Context.new
    end

    def clear_state
      @default_flagsts_container = nil
      @current_flagset = nil
    end
  end
end
