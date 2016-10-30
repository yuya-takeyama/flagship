RSpec.describe Flagship::FlagsetsContainer do
  let(:container) { described_class.new }
  let(:context) { ::Flagship::Context.new }

  describe '#set' do
    context 'when key is duplicated' do
      it 'raises DuplicatedFlagsetError' do
        flagset = ::Flagship::Flagset.new(:foo, {}, context)

        container.add(flagset)

        expect {
          container.add(flagset)
        }.to raise_error ::Flagship::FlagsetsContainer::DuplicatedFlagsetError
      end
    end
  end

  describe '#get' do
    context 'when the key exists' do
      it 'returns the flagset' do
        flagset = ::Flagship::Flagset.new(:foo, {}, context)

        container.add(flagset)

        expect(container.get(:foo)).to equal flagset
      end
    end

    context 'when the key does not exist' do
      it 'raises UndefinedFlagsetError' do
        expect {
          container.get(:foo)
        }.to raise_error ::Flagship::FlagsetsContainer::UndefinedFlagsetError
      end
    end
  end
end
