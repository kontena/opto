require_relative '../../spec_helper'
require 'base64'

describe Opto::Types::String do
  let(:subject) { described_class }

  context 'sanitize' do
    it 'converts a string to base64' do
      expect(Base64.decode64(subject.new(encode_64: true).sanitize_encode_64("foo"))).to eq "foo"
    end

    it 'converts base64 to string' do
      expect(subject.new(decode_64: true).sanitize_decode_64(Base64.encode64("foo"))).to eq "foo"
    end

    it 'converts to nil when string is empty' do
      expect(subject.new(empty_is_nil: true).sanitize_empty_is_nil("  \n")).to be_nil 
    end

    it 'converts to upcase' do
      expect(subject.new(upcase: true).sanitize_upcase("foo")).to eq "FOO"
    end

    it 'capitalizes' do
      expect(subject.new(capitalize: true).sanitize_capitalize("foo")).to eq "Foo"
    end

    it 'downcases' do
      expect(subject.new(downcase: true).sanitize_downcase("Foo")).to eq "foo"
    end

    it 'strips' do
      expect(subject.new(strip: true).sanitize_strip(" Foo  \n")).to eq "Foo"
    end

    it 'chomps' do
      expect(subject.new(chomp: true).sanitize_chomp(" Foo  \n")).to eq " Foo  "
    end
  end

  context 'validate' do
    it 'gives a validation error when string is too short' do
      expect(subject.new(min_length: 3).validate_min_length("12")).to match(/Too short/)
    end

    it 'gives no validation error when string is not too short' do
      expect(subject.new(min_length: 3).validate_min_length("123")).to be_nil
    end

    it 'gives a validation error when string is too long' do
      expect(subject.new(max_length: 3).validate_max_length("1234")).to match(/Too long/)
    end

    it 'gives no validation error when string is not too long' do
      expect(subject.new(max_length: 3).validate_max_length("123")).to be_nil
    end

    it 'gives no validation error when string is correct length' do
      expect(subject.new(min_length: 2, max_length: 3).validate_max_length("123")).to be_nil
    end

    it 'gives a validation error when string is not correct length' do
      expect(subject.new(min_length: 2, max_length: 3).validate_min_length("1")).to match(/Too short/)
      expect(subject.new(min_length: 2, max_length: 3).validate_max_length("1234")).to match(/Too long/)
    end
  end

end


