require 'spec_helper'

describe Opto do
  it 'has a version number' do
    expect(Opto::VERSION).not_to be nil
  end

  describe '#new' do
    it 'can create options' do
      expect(Opto.new(type: :string, name: 'gneh')).to be_kind_of(Opto::Option)
    end

    it 'can create option groups' do
      expect(Opto.new([{type: :string, name: 'gneh'}, {type: :integer, name: 'flof'}])).to be_kind_of(Opto::Group)
      expect(Opto.new([{type: :string, name: 'gneh'}, {type: :integer, name: 'flof'}]).first).to be_kind_of(Opto::Option)
    end

    it 'can create option groups from hashes' do
      expect(Opto.new(gneh: {type: :string}, flof: {type: :integer})).to be_kind_of(Opto::Group)
    end

    it 'raises if trying to pass something strange' do
      expect{Opto.new('fleff')}.to raise_error(TypeError)
      expect{Opto.new(['fleff'])}.to raise_error(TypeError)
    end

    describe '#read' do
      it 'reads a yaml file and creates an option' do
        expect(File).to receive(:read).with('/tmp/foo').and_return(
          YAML.dump(
            name: 'gnur',
            type: 'string'
          )
        )
        expect(Opto.read('/tmp/foo')).to be_kind_of(Opto::Option)
      end

      it 'reads a yaml file and creates an option group' do
        expect(File).to receive(:read).with('/tmp/foo').and_return(
          YAML.dump(
            [
              { name: 'gnur', type: 'string' },
              { name: 'bruf', type: 'string' }
            ]
          )
        )
        expect(Opto.read('/tmp/foo')).to be_kind_of(Opto::Group)
      end

      it 'reads a yaml file and creates an option group based on a key in the yaml' do
        expect(File).to receive(:read).with('/tmp/foo').and_return(
          YAML.dump(
            options: [
              { name: 'gnur', type: 'string' },
              { name: 'bruf', type: 'string' }
            ]
          )
        )
        expect(Opto.load('/tmp/foo', :options)).to be_kind_of(Opto::Group)
      end

      it 'reads a yaml file and creates an option based on a key in the yaml' do
        expect(File).to receive(:read).with('/tmp/foo').and_return(
          YAML.dump(
            option: { name: 'gnur', type: 'string' }
          )
        )
        expect(Opto.read('/tmp/foo', :option)).to be_kind_of(Opto::Option)
      end
    end
  end
end
