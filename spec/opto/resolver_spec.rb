require_relative '../spec_helper'
require 'ostruct'

describe Opto::Resolver do
  context 'base' do
    let(:subject) { described_class.new }

    it 'is a base class for resolvers so it raises if the required #resolve method is not defined' do
      expect{subject.resolve}.to raise_error(RuntimeError)
    end

    it 'creates an "origin" tag for itself' do
      expect(subject.origin).to eq :resolver
    end

    it 'raises if a suitable resolver is not found' do
      expect{Opto::Resolver.for(:foo_bar)}.to raise_error(NameError)
    end
  end
end
