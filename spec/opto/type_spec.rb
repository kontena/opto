require_relative '../spec_helper'

describe Opto::Type do
  let(:klass) {
    class TypeTest < Opto::Type
    end
    TypeTest
  }

  let(:subject) { klass.new }

  after(:each) do
    Object.send(:remove_const, :TypeTest) if Object.const_defined?(:TypeTest)
  end

  context 'validators' do
    it 'allows type handlers to define validators' do
      klass.validator :is_blerby do |value|
        unless value == 'blerb'
          "not blerb enough"
        end
      end
      subject.validate('blirb')
      expect(subject.errors[:validate_is_blerby]).to eq "not blerb enough"
      subject.validate('blerb')
      expect(subject.errors).to be_empty
    end
  end

  context 'sanitizers' do
    it 'allows type handlers to define sanitizers' do
      klass.sanitizer :blerbize do |value|
        value + " blerb"
      end
      expect(subject.sanitize('foo')).to eq 'foo blerb'
    end
  end

  describe '#valid?' do
    it 'returns true when validators find no errors' do
      instance = klass.new(required: false)
      expect(instance.valid?(nil)).to be_truthy
    end

    it 'returns true when validators find errors' do
      instance = klass.new(required: true)
      expect(instance.valid?(nil)).to be_falsey
    end
  end

  describe 'Type.for' do
    it 'returns a handler for a type using a name' do
      expect(Opto::Type.for(:type_test).name).to eq klass.name
    end

    it 'raises if a handler for the name cant be found' do
      expect{Opto::Type.for(:foo)}.to raise_error(NameError)
    end
  end

  describe '#type' do
    it 'returns a snakeized version of the class name' do
      expect(subject.type).to eq :type_test
    end
  end

  describe '#validate' do
    it 'adds the validator name to exception message if a validator raises' do
      klass.validator :always_raises do |value|
        raise StandardError, "Foo"
      end
      expect{subject.validate('bleh')}.to raise_error(StandardError) do |ex|
        expect(ex.message).to match(/Validator validate_always_raises : Foo/)
      end
    end
  end

  describe '#sanitize' do
    it 'adds the sanitizer name to exception message if a sanitizer raises' do
      klass.sanitizer :always_raises do |value|
        raise StandardError, "Foo"
      end
      expect{subject.sanitize('bleh')}.to raise_error(StandardError) do |ex|
        expect(ex.message).to match(/Sanitizer sanitize_always_raises : Foo/)
      end
    end
  end

  context 'default validators' do
    context ':presence' do
      it 'adds an error when a required value is nil' do
        instance = klass.new(required: true)
        instance.validate(nil)
        expect(instance.errors[:presence]).to match(/Required/)
      end

      it 'does not add an error when a required value is present' do
        instance = klass.new(required: true)
        instance.validate('foo')
        expect(instance.errors[:presence]).to be_nil
      end

      it 'does not add an error when value is nil and the option is not required' do
        instance = klass.new(required: false)
        instance.validate(nil)
        expect(instance.errors[:presence]).to be_nil
      end
    end

    context ':in' do
      it 'adds an error unless the :in array contains the value' do
        instance = klass.new(in: ['foo', 'blerb'])
        expect(instance.validate_in('gnaah')).to match(/Value.*not in/)
      end

      it 'does not add an error if the :in array contains the value' do
        instance = klass.new(in: ['foo', 'blerb'])
        expect(instance.validate_in('blerb')).not_to be_kind_of(String)
      end
    end
  end
end

