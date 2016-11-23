require_relative '../spec_helper'
require 'ostruct'

describe Opto::Setter do
  after(:each) do
    Object.send(:remove_const, :SetterTest) if Object.const_defined?(:SetterTest)
  end

  context 'base' do
    let(:klass) {
      class SetterTest < Opto::Setter
      end
      SetterTest
    }

    let(:subject) { klass.new }

    it 'is a base class for resolvers so it raises if the required #set method is not defined' do
      expect{subject.set(nil)}.to raise_error(RuntimeError)
    end

    it 'creates a "target" tag for itself' do
      expect(subject.target).to eq :setter_test
    end

    it 'can return a suitable setter by name' do
      expect(Opto::Setter.for(:setter_test).name).to eq klass.name
    end

    it 'raises if a suitable resolver is not found' do
      expect{Opto::Setter.for(:foo_bar)}.to raise_error(NameError)
    end

    it 'knows its parent option' do
      expect(Opto::Setter.for(:setter_test).new('hint', OpenStruct.new(name: 'foo')).option.name).to eq 'foo'
      expect(Opto::Setter.for(:setter_test).new('hint', OpenStruct.new(name: 'foo')).hint).to eq 'hint'
    end
  end
end

