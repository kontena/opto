require_relative '../../spec_helper'

describe Opto::Resolvers::Yaml do

  describe '#resolve' do
    let(:subject) { described_class }

    it 'raises if hint is not a hash' do
      expect{subject.new(nil).resolve}.to raise_error(TypeError)
    end

    it 'raises if hint hash does not contain file' do
      expect{subject.new(key: 'foo').resolve}.to raise_error(TypeError)
    end

    it 'reads values from a yaml file into a string' do
      expect(File).to receive(:read).with('foofoo.yml').and_return(YAML.dump('abc' => '123'))
      allow(File).to receive(:read).and_call_original
      opt = Opto::Option.new(type: :string, from: { yaml: { file: 'foofoo.yml', key: 'abc' } } )
      expect(opt.value).to eq '123'
    end

    it 'reads values from a nested yaml file into a string' do
      expect(File).to receive(:read).with('foofoo.yml').and_return(YAML.dump('abc' => { 'def' => '123' }))
      allow(File).to receive(:read).and_call_original
      opt = Opto::Option.new(type: :string, from: { yaml: { file: 'foofoo.yml', key: 'abc.def' } } )
      expect(opt.value).to eq '123'
    end

    it 'reads values from a yaml file into a string without a key' do
      expect(File).to receive(:read).with('foofoo.yml').and_return("hello")
      allow(File).to receive(:read).and_call_original
      opt = Opto::Option.new(type: :string, from: { yaml: { file: 'foofoo.yml' } } )
      expect(opt.value).to eq 'hello'
    end

    it 'reads values from a yaml file into an array' do
      expect(File).to receive(:read).with('foofoo.yml').and_return(YAML.dump('abc' => ['123', '456']))
      allow(File).to receive(:read).and_call_original
      opt = Opto::Option.new(type: :array, from: { yaml: { file: 'foofoo.yml', key: 'abc' } } )
      expect(opt.value).to eq ['123', '456']
    end
  end
end
