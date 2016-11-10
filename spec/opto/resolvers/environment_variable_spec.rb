require_relative '../../spec_helper'

describe Opto::Resolvers::Env do

  let(:subject) { described_class }

  describe '#resolve' do
    it 'raises if variable name is not set' do
      expect{subject.new(nil).resolve}.to raise_error(ArgumentError)
    end

    it 'gets a value from env' do
      expect(ENV).to receive(:[]).with('BLERB').and_return('chong!')
      expect(subject.new('BLERB').resolve).to eq 'chong!'
    end

    it 'converts a number to a number' do
      expect(ENV).to receive(:[]).with('BLERB').and_return('1')
      expect(subject.new('BLERB').resolve).to eq 1
    end

    it 'converts a boolean to a boolean' do
      expect(ENV).to receive(:[]).with('BLERB').and_return('true')
      expect(subject.new('BLERB').resolve).to be_truthy
      expect(ENV).to receive(:[]).with('BLIRB').and_return('false')
      expect(subject.new('BLIRB').resolve).to be_kind_of(FalseClass)
    end

    it 'converts a null to a nil' do
      expect(ENV).to receive(:[]).with('BLERB').and_return('null')
      expect(subject.new('BLERB').resolve).to be_nil
      expect(ENV).to receive(:[]).with('BLIRB').and_return('nil')
      expect(subject.new('BLIRB').resolve).to be_nil
    end
  end
end

