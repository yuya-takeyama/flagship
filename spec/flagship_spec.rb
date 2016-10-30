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
          enable :lambda_true_flag, if: -> { true }
          enable :lambda_false_flag, if: -> { false }
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
end
