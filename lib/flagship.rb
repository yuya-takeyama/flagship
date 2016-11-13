require "flagship/version"
require "flagship/context"
require "flagship/dsl"
require "flagship/feature"
require "flagship/flagset"
require "flagship/flagsets_container"

module Flagship
  class NoFlagsetSelectedError < ::StandardError; end

  def self.define(key, options = {}, &block)
    context = self.default_context
    base = options[:extend] ? self.get_flagset(options[:extend]) : nil
    self.default_flagsets_container.add ::Flagship::Dsl.new(key, context, base, &block).flagset
  end

  def self.enabled?(key)
    self.current_flagset.enabled?(key)
  end

  def self.set_context(key, value)
    self.default_context.__set(key, value)
  end

  def self.select_flagset(key)
    @@current_flagset = self.default_flagsets_container.get(key)
  end

  # Deprecated: Use select_flagset
  def self.set_flagset(key)
    self.select_flagset(key)
  end

  def self.features
    self.current_flagset.features
  end

  def self.get_flagset(key)
    self.default_flagsets_container.get(key)
  end

  def self.default_flagsets_container
    @@default_flagsts_container ||= ::Flagship::FlagsetsContainer.new
  end

  def self.current_flagset
    @@current_flagset or raise NoFlagsetSelectedError.new('No flagset is selected')
  end

  def self.default_context
    @@default_context ||= ::Flagship::Context.new
  end

  def self.clear_state
    @@default_flagsts_container = nil
    @@current_flagset = nil
  end
end
