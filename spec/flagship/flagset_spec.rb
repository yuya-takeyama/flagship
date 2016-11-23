RSpec.describe Flagship::Flagset do
  let(:context) { ::Flagship::Context.new }

  describe '#enabled?' do
    let(:flagset) do
      described_class.new(:foo, {
        true_flag: ::Flagship::Feature.new(:true_flag, true, context),
        false_flag: ::Flagship::Feature.new(:false_flag, false, context),
        lambda_true_flag: ::Flagship::Feature.new(:lambda_true_flag, ->(context) { true }, context),
        lambda_false_flag: ::Flagship::Feature.new(:lambda_false_flag, ->(context) { false }, context),
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

  describe 'extending' do
    let(:base) do
      described_class.new(:base, {
        true_flag: ::Flagship::Feature.new(:true_flag, true, context, {foo: :FOO}),
        false_flag: ::Flagship::Feature.new(:false_flag, false, context, {bar: :BAR}),
        lambda_true_flag: ::Flagship::Feature.new(:lambda_true_flag, ->(context) { true }, context),
        lambda_false_flag: ::Flagship::Feature.new(:lambda_false_flag, ->(context) { false }, context),
      })
    end

    it 'extends base flagset' do
      flagset = described_class.new(:extending, {}, base)

      expect(flagset.enabled?(:true_flag)).to be true
      expect(flagset.enabled?(:false_flag)).to be false
      expect(flagset.enabled?(:lambda_true_flag)).to be true
      expect(flagset.enabled?(:lambda_false_flag)).to be false
    end

    it 'extends tags of base flagset' do
      flagset = described_class.new(:extending, {
        false_flag: ::Flagship::Feature.new(:false_flag, false, context, {bar: :BARBAR, baz: :BAZ}),
        lambda_false_flag: ::Flagship::Feature.new(:lambda_false_flag, ->(context) { false }, context, {foobar: :FOOBAR}),
      }, base)

      expect(flagset.features[0].tags).to eq(foo: :FOO)
      expect(flagset.features[1].tags).to eq(bar: :BARBAR, baz: :BAZ)
      expect(flagset.features[2].tags).to eq({})
      expect(flagset.features[3].tags).to eq({foobar: :FOOBAR})
    end

    context 'with overriding flags' do
      it 'changes flags' do
        flagset = described_class.new(:extending, {
          true_flag: ::Flagship::Feature.new(:true_flag, false, context),
          false_flag: ::Flagship::Feature.new(:false_flag, true, context),
          lambda_true_flag: ::Flagship::Feature.new(:lambda_true_flag, ->(context) { false }, context),
          lambda_false_flag: ::Flagship::Feature.new(:lambda_false_flag, ->(context) { true }, context),
        }, base)

        expect(flagset.enabled?(:true_flag)).to be false
        expect(flagset.enabled?(:false_flag)).to be true
        expect(flagset.enabled?(:lambda_true_flag)).to be false
        expect(flagset.enabled?(:lambda_false_flag)).to be true
      end
    end

    context 'with new flags' do
      it 'adds flags' do
        flagset = described_class.new(:extending, {
          new_true_flag: ::Flagship::Feature.new(:new_true_flag, true, context),
          new_false_flag: ::Flagship::Feature.new(:new_false_flag, false, context),
          new_lambda_true_flag: ::Flagship::Feature.new(:new_lambda_true_flag, ->(context) { true }, context),
          new_lambda_false_flag: ::Flagship::Feature.new(:new_lambda_false_flag, ->(context) { false }, context),
        }, base)

        expect(flagset.enabled?(:new_true_flag)).to be true
        expect(flagset.enabled?(:new_false_flag)).to be false
        expect(flagset.enabled?(:new_lambda_true_flag)).to be true
        expect(flagset.enabled?(:new_lambda_false_flag)).to be false
      end
    end
  end
end
