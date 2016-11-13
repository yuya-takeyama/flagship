RSpec.describe Flagship::Feature do
  let(:context) { ::Flagship::Context.new }

  describe '#enabled?' do
    it 'returns true if feature is enabled' do
      feature = ::Flagship::Feature.new(:foo, true, context)
      expect(feature.enabled?).to be true
    end

    it 'returns false if feature is disabled' do
      feature = ::Flagship::Feature.new(:foo, false, context)
      expect(feature.enabled?).to be false
    end

    it 'returns true if feature is conditionally enabled' do
      feature = ::Flagship::Feature.new(:foo, ->(context) { true }, context)
      expect(feature.enabled?).to be true
    end

    it 'returns false if feature is conditionally disabled' do
      feature = ::Flagship::Feature.new(:foo, ->(context) { false }, context)
      expect(feature.enabled?).to be false
    end

    context 'with env variable' do
      it 'returns true if env is set as "1"' do
        feature = ::Flagship::Feature.new(:foo, false, context)
        stub_env(FLAGSHIP_FOO: '1')
        expect(feature.enabled?).to be true
      end

      it 'returns true if env is set as "true"' do
        feature = ::Flagship::Feature.new(:foo, false, context)
        stub_env(FLAGSHIP_FOO: 'true')
        expect(feature.enabled?).to be true
      end

      it 'returns false if env is set as "0"' do
        feature = ::Flagship::Feature.new(:foo, true, context)
        stub_env(FLAGSHIP_FOO: '0')
        expect(feature.enabled?).to be false
      end

      it 'returns false if env is set as "false"' do
        feature = ::Flagship::Feature.new(:foo, true, context)
        stub_env(FLAGSHIP_FOO: 'false')
        expect(feature.enabled?).to be false
      end

      it 'returns false if env is set as ""' do
        feature = ::Flagship::Feature.new(:foo, true, context)
        stub_env(FLAGSHIP_FOO: '')
        expect(feature.enabled?).to be false
      end
    end
  end

  def stub_env(hash = {})
    stub_const 'ENV', ENV.to_hash.merge(hash.map{|k, v| [k.to_s, v] }.to_h)
  end
end
