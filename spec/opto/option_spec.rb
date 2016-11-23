require_relative '../spec_helper'

describe Opto::Option do
  context 'class methods' do
    let(:subject) { described_class }

    it 'responds to #new' do
      expect(subject).to respond_to(:new)
    end

    it 'creates an instance' do
      expect{subject.new(name: 'foo', type: 'string')}.not_to raise_error
    end
  end

  context 'instance methods' do
    let(:base_opts) { { name: 'foo', type: 'string', from: { env: 'FOOENV' }, description: 'foodesc', strip: true, value: 'val', default: 'def', to: { env: 'BARENV' } } }
    let(:klass) { described_class }
    let(:subject) { klass.new(base_opts) }
 
    describe '#to_h' do
      it 'has a full set of keys/values' do
        hash = subject.to_h
        expect(hash[:name]).to eq 'foo'
        expect(hash[:type]).to eq 'string'
        expect(hash[:description]).to eq 'foodesc'
        expect(hash[:from][:env]).to eq 'FOOENV'
        expect(hash[:strip]).to be_truthy
        expect(hash[:value]).to eq 'val'
        expect(hash[:default]).to eq 'def'
        expect(hash[:errors]).to be_nil
      end

      it 'includes errors when called with with_errors: true' do
        hash = subject.to_h(with_errors: true)
        expect(hash[:errors]).to be_kind_of(Hash)
      end

      it 'is the same again if passed through #new' do
        expect(subject.to_h).to eq klass.new(subject.to_h).to_h
      end
    end

    describe '#set' do
      it 'sets the option value' do
        subject.set('bleh')
        expect(subject.value).to eq 'bleh'
      end

      it 'sanitizes the value' do
        expect(subject.handler).to receive(:sanitize).with('bleh').and_return('BLEH')
        subject.set('bleh')
        expect(subject.value).to eq 'BLEH'
      end

      it 'validates the value' do
        expect(subject.handler).to receive(:validate).with('bleh').and_return(true)
        subject.set('bleh')
      end

      it 'has alias value=' do
        subject.value = 'bleh'
        expect(subject.value).to eq 'bleh'
      end
    end

    describe '#validate' do
      it 'uses the type handler for validations' do
        subject.set('bleh')
        expect(subject.handler).to receive(:validate).with('bleh').and_return(true)
        subject.validate
      end

      it 'adds the option name in the exception message if a validator raises' do
        subject.value = 'bleh'

        subject.handler.class.validator :always_raises do |value|
          raise TypeError, "Hello"
        end

        expect{subject.validate}.to raise_error(TypeError) do |ex|
          expect(ex.message).to match(/Validation for foo.*always_raises/)
        end
        subject.handler.class.validators.delete(:validate_always_raises)
      end
    end

    describe '#handler' do
      let(:type) { double(:type) }

      before(:each) { allow(type).to receive(:valid?).and_return(true) }

      it 'gets a type handler from Opto::Type' do
        expect(Opto::Type).to receive(:for).with('string').and_return(type)
        expect(type).to receive(:new).with(hash_including(strip: true)).and_return(type)
        allow(type).to receive(:sanitize).and_return('foo')
        allow(type).to receive(:validate).and_return(true)
        expect(subject.handler).to be type
      end
    end

    describe '#value' do
      it 'returns the option value' do
        subject.set('bleh')
        expect(subject.value).to eq 'bleh'
      end

      it 'uses resolvers to obtain a value if no value is present' do
        instance = klass.new(base_opts.merge(default: nil, value: nil))
        expect(instance).to receive(:resolve).and_return('blerb')
        expect(instance.value).to eq 'blerb'
      end
    end

    describe '#setters' do
      it 'returns an array of Setters' do
        expect(subject.setters.all? {|r| r.kind_of?(Opto::Setter) }).to be_truthy
      end
    end

    describe '#output' do
      let(:setter) { double(:setter) }

      before(:each) do
        expect(Opto::Setter).to receive(:for).with(:env).and_return(setter)
        allow(setter).to receive(:target).and_return('double')
      end

      it 'sets the value of the option to target' do
        expect(setter).to receive(:new) do |var, opt|
          expect(var).to eq 'BARENV'
          expect(opt).to be subject
        end.and_return(setter)
        expect(setter).to receive(:set) do |val|
          expect(val).to eq 'blerb'
        end.and_return(true)
        subject.set('blerb')
        subject.output
      end

      it 'calls before & after' do
        expect(setter).to receive(:new).and_return(setter)
        expect(setter).to receive(:set).and_return(true)
        allow(setter).to receive(:respond_to?).and_return(true)
        expect(setter).to receive(:before).and_return(true)
        expect(setter).to receive(:after).and_return(true)
        subject.set('blerb')
        subject.output
      end

      it 'adds the option name in the exception message if a setter raises' do
        expect(setter).to receive(:new).and_return(setter)
        expect(setter).to receive(:set).and_raise(ArgumentError, "boo")
        expect{subject.output}.to raise_error(ArgumentError) do |ex|
          expect(ex.message).to start_with("Setter 'double' for 'foo' :")
        end
      end
    end

    describe '#resolvers' do
      it 'returns an array of Resolvers' do
        expect(subject.resolvers.all? {|r| r.kind_of?(Opto::Resolver) }).to be_truthy
      end
    end

    describe '#resolve' do

      let(:resolver) { double(:resolver) }

      before(:each) do
        expect(Opto::Resolver).to receive(:for).with(:env).and_return(resolver)
        expect(Opto::Resolver).to receive(:for).with(:default).and_return(resolver)
        allow(resolver).to receive(:new).and_return(resolver)
        allow(resolver).to receive(:origin).and_return('double')
      end

      it 'returns a resolved value' do
        expect(resolver).to receive(:resolve).and_return('blerbz')
        instance = klass.new(base_opts.merge(from: { env: 'FOO_OPT'}, value: nil, default: nil))
        expect(instance.value).to eq 'blerbz'
      end

      it 'adds the option name in the exception message if a resolver raises' do
        instance = klass.new(base_opts.merge(from: { env: nil }, value: nil, default: nil))
        expect(resolver).to receive(:resolve).and_raise(ArgumentError, "boo")
        expect{instance.value}.to raise_error(ArgumentError) do |ex|
          expect(ex.message).to start_with("Resolver 'double' for 'foo' :")
        end
      end

      it 'calls before & after' do
        allow(resolver).to receive(:respond_to?).and_return(true)
        expect(resolver).to receive(:before).and_return(true)
        expect(resolver).to receive(:after).and_return(true)
        expect(resolver).to receive(:resolve).and_return('blerbz')
        instance = klass.new(base_opts.merge(from: { env: 'FOO_OPT'}, value: nil, default: nil))
        expect(instance.value).to eq 'blerbz'
      end
    end

    describe '#normalize_from_to' do
      it 'can handle an array that has strings/symbols' do
        origins = subject.normalize_from_to([:env, 'default'])
        expect(origins).to have_key(:env)
        expect(origins[:env]).to eq subject.name
        expect(origins).to have_key(:default)
        expect(origins[:default]).to eq subject.name
        expect(origins.size).to eq 2
      end

      it 'can handle an array that has hashes' do
        origins = subject.normalize_from_to([{:env => 'foo'}, {'default' => nil}])
        expect(origins).to have_key(:env)
        expect(origins[:env]).to eq 'foo'
        expect(origins).to have_key(:default)
        expect(origins[:default]).to be_nil
        expect(origins.size).to eq 2
      end

      it 'can handle an array that has a nil' do
        expect(subject.normalize_from_to([nil])).to eq ({})
      end

      it 'raises for an array that has something else' do
        expect{subject.normalize_from_to([5])}.to raise_error(TypeError)
      end

      it 'can handle a hash' do
        origins = subject.normalize_from_to(env: 'foo')
        expect(origins).to have_key(:env)
        expect(origins[:env]).to eq 'foo'
        expect(origins.size).to eq 1
      end

      it 'can handle a lone string/sym' do
        expect(subject.normalize_from_to(:env)).to eq ({ env: subject.name })
        expect(subject.normalize_from_to('env')).to eq ({ env: subject.name })
      end

      it 'can handle nil' do
        expect(subject.normalize_from_to(nil)).to eq ({})
      end

      it 'raises when something else' do
        expect{subject.normalize_from_to(5)}.to raise_error(TypeError)
      end
    end

    describe '#required?' do
      it 'returns true when option is required' do
        instance = klass.new(base_opts.merge(default: nil, required: true))
        expect(instance.required?).to be_truthy
      end

      it 'returns false when option is not required' do
        instance = klass.new(base_opts.merge(default: nil, required: false))
        expect(instance.required?).to be_falsey
      end
    end

    describe '#valid?' do
      it 'delegates to type handler' do
        subject.set('bleh')
        expect(subject.handler).to receive(:valid?).with('bleh').and_return(true)
        subject.valid?
      end
    end

    describe '#errors' do
      it 'delegates to type handler' do
        expect(subject.handler).to receive(:errors).and_return({})
        subject.errors
      end
    end
  end

  context '#group_member' do
    let(:group) do 
      Opto::Group.new(
        [
          { name: 'foo', type: :string },
          { name: 'bar', type: :integer, value: 2 },
          { name: 'skip_if_foo', type: :string, skip_if: 'foo' },
          { name: 'only_if_bar', type: :string, only_if: 'bar' },
          { name: 'only_if_bar_2', type: :string, only_if: { 'bar' => 2 } },
          { name: 'only_if_bar_3_foo_not_baz', type: :string, skip_if: { 'foo' => 'baz' }, only_if: { 'bar' => 3 } },
          { name: 'only_if_bar_and_foo', type: :string, only_if: [ 'bar', 'foo' ] }
        ]
      )
    end

    it 'knows its group' do
      expect(group.first.group).to eq group
    end

    it 'finds group buddies' do
      expect(group.last.group.option('foo').name).to eq 'foo'
      expect(group.last.group.option('foo').type).to eq 'string'
    end

    it 'knows values of group buddies' do
      expect(group.last.value_of('bar')).to eq 2
    end

    it 'knows when to skip' do
      expect(group.option('skip_if_foo').skip?).to be_falsey
      group.option('foo').value = 'baz'
      expect(group.option('skip_if_foo').skip?).to be_truthy

      group.option('bar').value = 2
      expect(group.option('only_if_bar').skip?).to be_falsey
      group.option('bar').value = nil
      expect(group.option('only_if_bar').skip?).to be_truthy

      group.option('bar').value = 2
      expect(group.option('only_if_bar_2').skip?).to be_falsey
      group.option('bar').value = 3
      expect(group.option('only_if_bar_2').skip?).to be_truthy

      group.option('bar').value = 3
      group.option('foo').value = 'baz'
      expect(group.option('only_if_bar_3_foo_not_baz').skip?).to be_truthy

      group.option('bar').value = 3
      group.option('foo').value = 'bar'
      expect(group.option('only_if_bar_3_foo_not_baz').skip?).to be_falsey

      group.option('bar').value = nil
      group.option('foo').value = 'yes'
      expect(group.option('only_if_bar_and_foo').skip?).to be_truthy
      group.option('bar').value = 2
      expect(group.option('only_if_bar_and_foo').skip?).to be_falsey
      group.option('foo').value = nil
      expect(group.option('only_if_bar_and_foo').skip?).to be_truthy
    end

    it 'raises if ifs are not kosher' do
      expect{Opto::Option.new(name: 'foo', type: :string, only_if: 3)}.to raise_error(TypeError)
    end

    it 'merges from/to defaults from group' do
      grp = Opto::Group.new(defaults: { from: :env, to: :env})
      instance = grp.build_option(type: :string, name: 'foo', from: { file: '/tmp/foo.txt' })
      expect(instance.from[:env]).to eq 'foo'
      expect(instance.from[:file]).to eq '/tmp/foo.txt'
      expect(instance.to[:env]).to eq 'foo'
    end
  end
end

