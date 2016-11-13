RSpec.describe Flagship do
  before do
    Flagship.clear_state
  end

  describe '.define' do
    it 'defines a flagset' do
      Flagship.define(:foo) do
        enable :bar
      end

      flagset = Flagship.default_flagsets_container.get(:foo)

      expect(flagset.enabled?(:bar)).to be true
    end

    context 'with :extend option' do
      it 'extends base flagset' do
        Flagship.define(:base) do
          enable :foo
        end

        Flagship.define(:extending, extend: :base) do
          enable :bar
        end

        flagset = Flagship.default_flagsets_container.get(:extending)

        expect(flagset.enabled?(:foo)).to be true
        expect(flagset.enabled?(:bar)).to be true
      end
    end
  end

  describe '.enabled?' do
    context 'when no flagset is selected' do
      it 'raises NoFlagsetSelectedError' do
        expect {
          Flagship.enabled?(:foo)
        }.to raise_error ::Flagship::NoFlagsetSelectedError
      end
    end

    context 'when a flagset is selected' do
      before do
        Flagship.define(:foo) do
          enable :true_flag
          disable :false_flag
          enable :lambda_true_flag, if: ->(context) { true }
          enable :lambda_false_flag, if: ->(context) { false }
        end

        Flagship.set_flagset(:foo)
      end

      context 'and the feature is enabled' do
        it 'returns true' do
          expect(Flagship.enabled?(:true_flag)).to be true
        end
      end

      context 'and the feature is disabled' do
        it 'returns false' do
          expect(Flagship.enabled?(:false_flag)).to be false
        end
      end

      context 'and the feature is enabled conditionally' do
        context 'and the condition returns true' do
          it 'returns true' do
            expect(Flagship.enabled?(:lambda_true_flag)).to be true
          end
        end

        context 'and the condition returns true' do
          it 'returns false' do
            expect(Flagship.enabled?(:lambda_false_flag)).to be false
          end
        end
      end
    end
  end

  describe '.set_context' do
    it 'sets context variable which is accessible from :if block' do
      Flagship.set_context :var, 'VAR'

      Flagship.define :foo do
        enable :bar, if: ->(context) { context.var == 'VAR' }
        enable :baz, if: ->(context) { context.var != 'VAR' }
      end

      Flagship.set_flagset(:foo)

      expect(Flagship.enabled?(:bar)).to be true
      expect(Flagship.enabled?(:baz)).to be false
    end

    it 'sets context method which is callable from :if block' do
      Flagship.set_context :var, -> { 'VAR' }

      Flagship.define :foo do
        enable :bar, if: ->(context) { context.var == 'VAR' }
        enable :baz, if: ->(context) { context.var != 'VAR' }
      end

      Flagship.set_flagset(:foo)

      expect(Flagship.enabled?(:bar)).to be true
      expect(Flagship.enabled?(:baz)).to be false
    end
  end

  describe '.features' do
    it 'returns Feature objects' do
      Flagship.define :foo do
        enable :enabled_feature
        disable :disabled_feature
        enable :conditionally_enabled_feature, if: ->(context) { true }
        enable :conditionally_disabled_feature, if: ->(context) { false }
      end

      Flagship.set_flagset(:foo)

      features = Flagship.features

      expect(features[0].key).to eq :enabled_feature
      expect(features[0].enabled?).to be true

      expect(features[1].key).to eq :disabled_feature
      expect(features[1].enabled?).to be false

      expect(features[2].key).to eq :conditionally_enabled_feature
      expect(features[2].enabled?).to be true

      expect(features[3].key).to eq :conditionally_disabled_feature
      expect(features[3].enabled?).to be false
    end
  end
end
