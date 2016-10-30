RSpec.describe Flagship::Dsl do
  it 'creates a flagset with specified key' do
    flagset = ::Flagship::Dsl.new(:foo) {
      # noop
    }.flagset

    expect(flagset.key).to eq :foo
  end

  describe '#enable' do
    context 'without options' do
      it 'enables specified feature' do
        dsl = ::Flagship::Dsl.new(:foo) do
          enable :bar
        end

        expect(dsl.flagset.enabled?(:bar)).to be true
      end
    end

    context 'with :if option' do
      context 'and specified lambda returns true' do
        it 'enables specified feature' do
          dsl = ::Flagship::Dsl.new(:foo) do
            enable :bar, if: -> { true }
          end

          expect(dsl.flagset.enabled?(:bar)).to be true
        end
      end

      context 'and specified lambda returns false' do
        it 'enables specified feature' do
          dsl = ::Flagship::Dsl.new(:foo) do
            enable :bar, if: -> { false }
          end

          expect(dsl.flagset.enabled?(:bar)).to be false
        end
      end
    end
  end

  describe '#disable' do
    context 'without options' do
      it 'disables specified feature' do
        dsl = ::Flagship::Dsl.new(:foo) do
          disable :bar
        end

        expect(dsl.flagset.enabled?(:bar)).to be false
      end
    end

    context 'with :if option' do
      it 'raises InvalidOptionError' do
        expect {
          dsl = ::Flagship::Dsl.new(:foo) do
            disable :bar, if: -> { true }
          end

          dsl.flagset
        }.to raise_error ::Flagship::Dsl::InvalidOptionError
      end
    end
  end
end
