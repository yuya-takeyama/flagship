RSpec.describe Flagship::Flagset do
  describe '#enabled?' do
    let(:flagset) do
      described_class.new(:foo, {
        true_flag: true,
        false_flag: false,
        lambda_true_flag: -> { true },
        lambda_false_flag: -> { false },
      })
    end

    context 'when flag is not defined' do
      it 'raises UndefinedFlagError' do
        expect { flagset.enabled?(:undefined) }.to raise_error ::Flagship::Flagset::UndefinedFlagError
      end
    end

    context 'when flag is a boolean value' do
      context 'and the value is true' do
        it { expect(flagset.enabled?(:true_flag)).to be true }
      end

      context 'and the value is false' do
        it { expect(flagset.enabled?(:false_flag)).to be false }
      end
    end

    context 'when flag is a lambda' do
      context 'and it returns true' do
        it { expect(flagset.enabled?(:lambda_true_flag)).to be true }
      end

      context 'and it returns false' do
        it { expect(flagset.enabled?(:lambda_false_flag)).to be false }
      end
    end
  end
end
