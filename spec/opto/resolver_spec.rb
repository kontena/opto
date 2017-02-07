require_relative '../spec_helper'
require 'ostruct'

describe Opto::Resolver do
  after(:each) do
    # have to do it like this instead of Class.new because the class name is significant.
    Object.send(:remove_const, :ResolverTest) if Object.const_defined?(:ResolverTest)
  end

  context 'base' do
    let(:klass) {
      class ResolverTest < Opto::Resolver
      end
      ResolverTest
    }

    let(:subject) { klass.new }

    it 'is a base class for resolvers so it raises if the required #resolve method is not defined' do
      expect{subject.resolve}.to raise_error(RuntimeError)
    end

    it 'creates an "origin" tag for itself' do
      expect(subject.origin).to eq :resolver_test
    end

    it 'can return a suitable resolver by name' do
      expect(Opto::Resolver.for(:resolver_test).name).to eq klass.name
    end

    it 'raises if a suitable resolver is not found' do
      expect{Opto::Resolver.for(:foo_bar)}.to raise_error(NameError)
    end

    it 'knows its parent option' do
      expect(Opto::Resolver.for(:resolver_test).new('hint', OpenStruct.new(name: 'foo')).option.name).to eq 'foo'
      expect(Opto::Resolver.for(:resolver_test).new('hint', OpenStruct.new(name: 'foo')).hint).to eq 'hint'
    end

    it 'only tries once' do
      expect(subject).to receive(:resolve).once.and_return(nil)
      subject.try_resolve
      subject.try_resolve
    end
  end
end
