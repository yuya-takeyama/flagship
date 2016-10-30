require "flagship/version"
require "flagship/dsl"
require "flagship/flagset"
require "flagship/flagsets_container"

module Flagship
  class NoFlagsetSelectedError < ::StandardError; end

  def self.define(key, &block)
    self.default_flagsets_container.add ::Flagship::Dsl.new(key, &block).flagset
  end

  def self.enabled?(key)
    self.current_flagset.enabled?(key)
  end

  def self.set_flagset(key)
    @@current_flagset = self.default_flagsets_container.get(key)
  end

  def self.default_flagsets_container
    @@default_flagsts_container ||= ::Flagship::FlagsetsContainer.new
  end

  def self.current_flagset
    @@current_flagset or raise NoFlagsetSelectedError.new('No flagset is selected')
  end

  def self.clear_state
    @@default_flagsts_container = nil
    @@current_flagset = nil
  end
end
