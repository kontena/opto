require_relative '../../spec_helper'

describe Opto::Types::Enum do
  let(:subject) { described_class }

  it 'normalizes the options' do
    instance = subject.new(options: ['a', 'b', 'c'])
    expect(instance.options[:options].size).to eq 3
    expect(instance.options[:options].first[:value]).to eq 'a'
    expect(instance.options[:options].first[:label]).to eq 'a'
    expect(instance.options[:options].first[:description]).to eq 'a'
    instance = subject.new(options: [
      { value: 'a', label: 'b', description: 'c' },
      { value: 'b', label: 'c', description: 'd' }
    ])
    expect(instance.options[:options].size).to eq 2
    expect(instance.options[:options].first[:value]).to eq 'a'
    expect(instance.options[:options].first[:label]).to eq 'b'
    expect(instance.options[:options].first[:description]).to eq 'c'
    expect(instance.options[:options].last[:value]).to eq 'b'
    expect(instance.options[:options].last[:label]).to eq 'c'
    expect(instance.options[:options].last[:description]).to eq 'd'
    instance = subject.new(options: { 'a' => 'b' })
    expect(instance.options[:options].size).to eq 1
    expect(instance.options[:options].first[:value]).to eq 'a'
    expect(instance.options[:options].first[:label]).to eq 'a'
    expect(instance.options[:options].first[:description]).to eq 'b'
    instance = subject.new(options: nil)
    expect(instance.options[:options]).to be_empty
  end

  it 'raises if the options are not kosher' do
    expect{subject.new(options: "blerb")}.to raise_error(TypeError)
    expect{subject.new(options: [ {foo: 'bar'}])}.to raise_error(TypeError)
    expect{subject.new(options: [ [] ])}.to raise_error(TypeError)
  end

  context 'validate' do
    it 'raises if no options are defined' do
      expect{subject.new(options: []).validate_options('foo')}.to raise_error(RuntimeError)
    end

    it 'raises if multiple options with same value are defined' do
      expect{subject.new(options: ['a', 'a', 'b']).validate_options('foo')}.to raise_error(RuntimeError)
    end

    it 'passes if all ok' do
      expect(subject.new(options: ['a', 'b', 'c']).validate_options('foo')).to be_nil
    end

    it 'overwrites the :in validator from Type' do
      expect(subject.new(options: ['a', 'b', 'c']).validate_in('foo')).to match(/Value is not one of the options/)
      expect(subject.new(options: ['a', 'b', 'c'], can_be_other: true).validate_in('foo')).to be_nil
      expect(subject.new(options: ['a', 'b', 'c'], in: ['a', 'b']).validate_in('foo')).to match(/Value is not one/)
      expect(subject.new(options: ['a', 'b', 'c'], in: ['a', 'b']).validate_in('b')).to be_nil
      expect(subject.new(options: ['a', 'b', 'c']).validate_in('b')).to be_nil
    end
  end
end
