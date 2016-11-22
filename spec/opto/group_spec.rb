require_relative '../spec_helper'

describe Opto::Group do
  let(:subject) { described_class }

  it 'creates a collection of options from an array' do
    instance = subject.new([{type: :string, name: 'foo'}, {type: :integer, name: 'bar'}])
    expect(instance.size).to eq 2
    expect(instance.first.name).to eq 'foo'
    expect(instance.last.name).to eq 'bar'
  end

  it 'creates a collection of options from a hash' do
    instance = subject.new(foo: {type: :string}, bar: {type: :integer})
    expect(instance.size).to eq 2
    expect(instance.first.name).to eq 'foo'
    expect(instance.last.name).to eq 'bar'
  end

  it 'creates a blank collection' do
    instance = subject.new
    expect(instance.size).to eq 0
  end

  it 'raises if something weird is passed in' do
    expect{subject.new(1)}.to raise_error(TypeError)
  end

  it 'can validate all options' do
    instance = subject.new([{type: :string, name: 'foo', value: nil, default: nil, required: true}, {type: :integer, name: 'bar', value: 1}])
    expect(instance.valid?).to be_falsey
    instance.first.value = 'foo'
    expect(instance.valid?).to be_truthy
  end

  it 'combines errors of all options' do
    instance = subject.new([{type: :string, name: 'foo', value: nil, default: nil, required: true}, {type: :integer, name: 'bar', value: 1, min: 3}])
    expect(instance.errors["foo"].values.join).to match(/Required/)
    expect(instance.errors["bar"].values.join).to match(/Too small/)
  end

  it 'can return an array of fields that contain errors' do
    instance = subject.new([{type: :string, name: 'foo', value: nil, default: nil, required: true}, {type: :integer, name: 'bar', value: 1}])
    expect(instance.options_with_errors.size).to eq 1
  end

  it 'converts the options to an array of hashes' do
    instance = subject.new([{type: :string, name: 'foo'}, {type: :integer, name: 'bar', value: 1}])
    arr = instance.to_a
    expect(arr.first[:name]).to eq 'foo'
    expect(arr.last[:name]).to eq 'bar'
    expect(arr.size).to eq 2
    expect(arr.all? {|a| a.kind_of?(Hash)}).to be_truthy
  end

  it 'converts the options to a hash of names and values with "values_only: true"' do
    instance = subject.new([{type: :string, name: 'foo'}, {type: :integer, name: 'bar', value: 1}])
    hash = instance.to_h(values_only: true)
    expect(hash['foo']).to be_nil
    expect(hash['bar']).to eq 1
  end

  it 'converts the options to a hash of names and opt definitions when "values_only: false"' do
    instance = subject.new([{type: :string, name: 'foo'}, {type: :integer, name: 'bar', value: 1}])
    hash = instance.to_h
    expect(hash['foo'][:type]).to eq 'string'
  end

  it 'can add a new option to the collection' do
    instance = subject.new([{type: :string, name: 'foo'}, {type: :integer, name: 'bar', value: 1}])
    instance.build_option(name: 'blerb', type: :string)
    expect(instance.size).to eq 3
    expect(instance.last.name).to eq 'blerb'
    instance = subject.new([{type: :string, name: 'foo'}, {type: :integer, name: 'bar', value: 1}])
    instance << Opto::Option.new(name: 'blerb', type: :string)
    expect(instance.size).to eq 3
    expect(instance.last.name).to eq 'blerb'
  end
end

