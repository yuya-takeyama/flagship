class Flagship::Flagset
  attr_reader :name

  class UndefinedFlagError < ::StandardError; end

  def initialize(name, flags)
    @name = name
    @flags = flags
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
