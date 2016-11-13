class Flagship::Flagset
  attr_reader :key

  class UndefinedFlagError < ::StandardError; end

  def initialize(key, features_hash, base = nil)
    @key = key
    @features = base ?
      base.features.map{ |f| [f.key, f] }.to_h.merge(features_hash) :
      features_hash
  end

  def enabled?(key)
    raise UndefinedFlagError.new("The flag :#{key} is not defined") unless @features.key? key


    @features[key].enabled?
  end

  def features
    @features.map { |key, feature| feature }
  end
end
