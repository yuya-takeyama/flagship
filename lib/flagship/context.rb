require 'forwardable'

class Flagship::Context
  extend Forwardable
  def_delegators :current_values, :clear

  def __set(key, value)
    current_values[key.to_sym] = value
  end

  def method_missing(name, args = [], &block)
    if current_values.key?(name)
      value = current_values[name]

      if value.respond_to?(:call)
        value.call
      else
        value
      end
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    current_values.key?(name) or super
  end

  def with_values(new_values, &block)
    original_values = current_values
    self.current_values = current_values.dup.merge(new_values)
    block.call
  ensure
    self.current_values = original_values
  end

  private

  def current_values
    Thread.current[:__flagship_context_values] ||= {}
  end

  def current_values=(new_values)
    Thread.current[:__flagship_context_values] = new_values
  end
end
