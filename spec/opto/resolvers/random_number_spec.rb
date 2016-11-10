require_relative '../../spec_helper'

describe Opto::Resolvers::RandomNumber do

  describe '#resolve' do
    let(:subject) { described_class }

    it 'generates a random number between :min and :max' do
      100.times do
        number = subject.new(min: 4, max: 10).resolve
        expect(number >= 4).to be_truthy
        expect(number <= 10).to be_truthy
      end
    end

    it 'raises if range is not set' do
      expect{subject.new(nil).resolve}.to raise_error(ArgumentError)
      expect{subject.new('foo').resolve}.to raise_error(TypeError)
      expect{subject.new(min: 4).resolve}.to raise_error(ArgumentError)
      expect{subject.new(max: 4).resolve}.to raise_error(ArgumentError)
    end
  end
end

