class Flagship::FlagsetsContainer
  class DuplicatedFlagsetError < ::StandardError; end
  class UndefinedFlagsetError < ::StandardError; end

  def initialize
    @flagsets = {}
  end

  def add(flagset)
    raise DuplicatedFlagsetError.new("Flagset :#{flagset.key} already exists") if @flagsets.key? flagset.key

    @flagsets[flagset.key] = flagset
  end

  def get(key)
    raise UndefinedFlagsetError.new("Flagset :#{key} does not exist") unless @flagsets.key? key

    @flagsets[key]
  end
end
