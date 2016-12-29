require_relative '../../spec_helper'

describe Opto::Types::Array do
  let(:subject) { described_class }

  context 'sanitize' do
    it 'converts a string to an array' do
      expect(subject.new(split: ';').sanitize_split("foo;foo;bar")).to eq ['foo', 'foo', 'bar']
    end

    it 'keeps the array intact when given an array' do
      expect(subject.new(split: ';').sanitize_split(["foo", "bar"])).to eq ['foo', 'bar']
    end

    it 'puts the item in an array if the original is not an array or a string' do
      expect(subject.new(split: ';').sanitize_split(1)).to eq [1]
    end

    it 'converts the array to a string' do
      expect(subject.new(join: ',').sanitize_output(['foo', 'foo', 'bar'])).to eq "foo,foo,bar"
    end

    it 'can return an array' do
      expect(subject.new.sanitize_output(['foo', 'foo', 'bar'])).to eq ['foo', 'foo', 'bar']
    end

    it 'can return a nil' do
      expect(subject.new.sanitize_output(nil)).to be_nil
    end

    it 'makes an empty array nil' do
      expect(subject.new(empty_is_nil: true).sanitize_empty_is_nil([])).to eq nil
    end

    it 'can sort' do
      expect(subject.new(sort: true).sanitize_sort(["abc", "efg", "bcd"])).to eq ['abc', 'bcd', 'efg']
    end

    it 'can uniq' do
      expect(subject.new(uniq: true).sanitize_uniq(["abc", "abc", "bcd"])).to eq ['abc', 'bcd']
    end

    it 'can compact' do
      expect(subject.new(compact: true).sanitize_compact(["abc", nil, "bcd"])).to eq ['abc', 'bcd']
    end

    it 'can count' do
      expect(subject.new(count: true).sanitize_output(["abc", "cde", "bcd"])).to eq 3
    end

    it 'should have an empty array initially' do
      arr = Opto::Option.new(type: :array, name: 'array')
      expect(arr.value).to be_empty
    end
  end
end
