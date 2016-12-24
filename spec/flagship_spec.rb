RSpec.describe Flagship do
  before do
    Flagship.clear_state
  end

  describe '.define' do
    it 'defines a flagset' do
      Flagship.define(:foo) do
        enable :bar, tag_a: true
      end

      flagset = Flagship.default_flagsets_container.get(:foo)

      expect(flagset.enabled?(:bar)).to be true
      expect(flagset.features.first.tags).to eq(tag_a: true)
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

    context 'using with_tags DSL' do
      it 'sets tags' do
        Flagship.define :foo do
          with_tags(tag_a: true) do
            enable :bar, tag_b: true
            disable :baz, tag_a: false

            with_tags(tag_c: false) do
              enable :foobar, tag_d: true
              enable :qux, tag_c: true
            end
          end
        end

        flagset = Flagship.default_flagsets_container.get(:foo)

        expect(flagset.enabled?(:bar)).to be true
        expect(flagset.enabled?(:baz)).to be false
        expect(flagset.features[0].tags).to eq(tag_a: true, tag_b: true)
        expect(flagset.features[1].tags).to eq(tag_a: false)
        expect(flagset.features[2].tags).to eq(tag_a: true, tag_c: false, tag_d: true)
        expect(flagset.features[3].tags).to eq(tag_a: true, tag_c: true)
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

        Flagship.select_flagset(:foo)
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

      Flagship.select_flagset(:foo)

      expect(Flagship.enabled?(:bar)).to be true
      expect(Flagship.enabled?(:baz)).to be false
    end

    it 'sets context method which is callable from :if block' do
      Flagship.set_context :var, -> { 'VAR' }

      Flagship.define :foo do
        enable :bar, if: ->(context) { context.var == 'VAR' }
        enable :baz, if: ->(context) { context.var != 'VAR' }
      end

      Flagship.select_flagset(:foo)

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

      Flagship.select_flagset(:foo)

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

    context 'can filter by' do
      let(:flagset) { Flagship.default_flagsets_container.get(:foo) }

      before do
        Flagship.define :foo do
          enable :enabled_feature
          disable :disabled_feature
          enable :conditionally_enabled_feature, if: ->(context) { true }
          enable :conditionally_disabled_feature, if: ->(context) { false }

          with_tags(tag_a: true) do
            enable :bar
          end

          with_tags(tag_b: false) do
            enable :baz
            enable :qux, tag_b: true, tag_c: true
          end
        end
      end

      context 'tags' do
        it do
          expect(flagset.features.tagged_any(tag_a: true).map(&:key)).to eq([:bar])
          expect(flagset.features.tagged_any(tag_b: false).map(&:key)).to eq([:baz])
        end

        it 'any' do
          expect(flagset.features.tagged_any(tag_a: true, tag_b: true).map(&:key)).to eq([:bar, :qux])
        end

        it 'all' do
          expect(flagset.features.tagged(tag_a: true, tag_b: true).map(&:key)).to eq([])
          expect(flagset.features.tagged(tag_b: true, tag_c: true).map(&:key)).to eq([:qux])

          # alias (more explicit)
          expect(flagset.features.tagged_all(tag_a: true, tag_b: true).map(&:key)).to eq([])
          expect(flagset.features.tagged_all(tag_b: true, tag_c: true).map(&:key)).to eq([:qux])

          # chained syntax
          expect(flagset.features.tagged(tag_a: true).tagged(tag_b: true).map(&:key)).to eq([])
          expect(flagset.features.tagged(tag_b: true).tagged(tag_c: true).map(&:key)).to eq([:qux])
        end
      end

      it 'enabled' do
        expect(flagset.features.enabled.map(&:key)).to eq([:enabled_feature, :conditionally_enabled_feature, :bar, :baz, :qux])
      end

      it 'disabled' do
        expect(flagset.features.disabled.map(&:key)).to eq([:disabled_feature, :conditionally_disabled_feature])
      end
    end

    context 'helper methods' do
      let(:flagset) { Flagship.default_flagsets_container.get(:foo) }

      it 'can be used within procs' do
        Flagship.define :foo do
          def is_eq(x, y)
            x == y
          end

          enable :bar, if: -> context { is_eq(2, 2) }
          enable :baz, if: -> context { is_eq(2, 6) }
        end

        expect(flagset.enabled?(:bar)).to be true
        expect(flagset.enabled?(:baz)).to be false
      end

      it 'can be symbolically referenced' do
        Flagship.define :foo do
          def is_true(context)
            true
          end

          def is_false(context)
            false
          end

          enable :qux, if: :is_true
          enable :quz, if: :is_false
        end

        expect(flagset.enabled?(:qux)).to be true
        expect(flagset.enabled?(:quz)).to be false
      end

      it 'can be placed after flag definitions' do
        Flagship.define :foo do
          enable :qux, if: :is_true
          enable :quz, if: :is_false

          def is_true(context)
            true
          end

          def is_false(context)
            false
          end
        end

        expect(flagset.enabled?(:qux)).to be true
        expect(flagset.enabled?(:quz)).to be false
      end

      it 'are not shared with other flagship declarations' do
        Flagship.define :foo do
          def is_true(context)
            true
          end

          enable :baz, if: :is_true
        end

        expect{
          Flagship.define :bar do
            enable :baz, if: :is_true
          end
        }.to raise_error(NameError)
      end

      it 'can be defined and included from modules' do
        module FooMethods
          def is_foo(context)
            true
          end
        end

        module OtherMethods
          def is_foo(context)
            false
          end
        end

        Flagship.define :foo do
          include FooMethods
          enable :feature, if: :is_foo
        end

        Flagship.define :bar do
          include OtherMethods
          enable :feature, if: :is_foo
        end

        Flagship.select_flagset(:foo)
        expect(Flagship.enabled?(:feature)).to be true

        Flagship.select_flagset(:bar)
        expect(Flagship.enabled?(:feature)).to be false
      end
    end
  end
end
