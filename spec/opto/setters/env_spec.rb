require_relative '../../spec_helper'

describe Opto::Setters::Env do

  describe '#set' do
    let(:subject) { described_class }

    it 'sets an env variable' do
      instance = subject.new('FNEF')
      expect(ENV).to receive(:[]=).with('FNEF', 'blerbz').and_return(true)
      instance.set('blerbz')
    end

    it 'sets an env variable using hash syntax' do
      instance = subject.new({:name => 'FNEF'})
      expect(ENV).to receive(:[]=).with('FNEF', 'blerbz').and_return(true)
      instance.set('blerbz')
    end

    it 'raises if hint not set' do
      instance = subject.new
      expect{instance.set('blerbz')}.to raise_error(ArgumentError)
    end
  end
end

