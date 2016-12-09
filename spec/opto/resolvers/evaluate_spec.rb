require_relative '../../spec_helper'

describe Opto::Resolvers::Evaluate do

  describe '#resolve' do
    let(:subject) { described_class }

    it 'performs simple calculations' do
      expect(subject.new('(5+2+(1*3))/2').resolve).to eq 5
    end

    it 'performs interpolation and calculation' do
      group = Opto::Group.new
      opt_1 = group.build_option(type: 'string', name: 'str', value: '4')
      opt_2 = group.build_option(type: 'integer', name: 'int', value: 4)
      opt_3 = group.build_option(type: 'integer', name: 'result', from: { evaluate: '${str}+${int}' })
      expect(opt_3.value).to eq 8
    end

    it 'raises if hint is not a string' do
      expect{subject.new(nil).resolve}.to raise_error(TypeError)
    end

    it 'raises if hint does not look like a calculation' do
      expect{subject.new('abcd').resolve}.to raise_error(TypeError)
    end
  end
end


