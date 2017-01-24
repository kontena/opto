require_relative '../spec_helper'

class SnakeTest
  using Opto::Extension::SnakeCase

  def self.snakeize(string)
    string.snakecase
  end
end

class FlexyHashTest
  using Opto::Extension::HashStringOrSymbolKey

  def initialize(key, value)
    @hash = { key => value }
  end

  def get_key(key)
    @hash[key]
  end

  def delete_key(key)
    @hash.delete(key)
  end

  def hash
    @hash
  end
end

describe Opto::Extension::SnakeCase do
  it 'snakeizes strings' do
    expect(SnakeTest.snakeize('FooBar')).to eq 'foo_bar'
  end
end

describe Opto::Extension::HashStringOrSymbolKey do
  it 'makes hashes work with either syms or strings' do
    expect(FlexyHashTest.new(:foo_bar, 'bleh').get_key('foo_bar')).to eq 'bleh'
    expect(FlexyHashTest.new('foo_bar', 'bleh').get_key('foo_bar')).to eq 'bleh'
    expect(FlexyHashTest.new('foo_bar', 'bleh').get_key(:foo_bar)).to eq 'bleh'
  end

  it 'also works with .delete' do
    output = FlexyHashTest.new('foo_bar', 'bleh')
    expect(output.get_key(:foo_bar)).to eq 'bleh'
    expect(output.get_key('foo_bar')).to eq 'bleh'
    output.delete_key(:foo_bar)
    expect(output.get_key(:foo_bar)).to be_nil
    expect(output.get_key('foo_bar')).to be_nil
    output = FlexyHashTest.new(:foo_bar, 'bleh')
    expect(output.get_key(:foo_bar)).to eq 'bleh'
    expect(output.get_key('foo_bar')).to eq 'bleh'
    output.delete_key('foo_bar')
    expect(output.get_key(:foo_bar)).to be_nil
    expect(output.get_key('foo_bar')).to be_nil
  end
end
