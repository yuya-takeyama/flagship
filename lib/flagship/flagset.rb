class Flagship::Flagset
  attr_reader :key, :flags

  class UndefinedFlagError < ::StandardError; end

  def initialize(key, flags, base = nil)
    @key = key
    @flags = base ? base.flags.merge(flags) : flags
  end

  def enabled?(key, if: nil)
    raise UndefinedFlagError.new("The flag :#{key} is not defined") unless @flags.key? key

    flag = @flags[key]

    if flag.respond_to?(:call)
      !!@flags[key].call
    else
      !!@flags[key]
    end
  end
end
