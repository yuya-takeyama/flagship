class Flagship::Flagset
  attr_reader :key, :helper_methods

  class UndefinedFlagError < ::StandardError; end

  def initialize(key, features_hash, base = nil, helper_methods = [])
    @key = key
    @features = base ?
      extend_features(features_hash, base) :
      features_hash
    @helper_methods = helper_methods
  end

  def enabled?(key)
    raise UndefinedFlagError.new("The flag :#{key} is not defined") unless @features.key? key


    @features[key].enabled?
  end

  def disabled?(key)
    !enabled?(key)
  end

  def features
    Flagship::Features.new @features.map { |key, feature| feature }
  end

  private

  def extend_features(features_hash, base)
    base.features.map { |f|
      [f.key, f]
    }.to_h.merge(features_hash) { |key, base_f, new_f|
      new_f.extend_feature(base_f)
    }
  end
end
