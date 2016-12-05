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

    it 'hexdigests md5' do
      expect(subject.new(hexdigest: 'md5').sanitize_hexdigest("foo")).to eq "acbd18db4cc2f85cedef654fccc4a4d8"
    end

    it 'hexdigests sha1' do
      expect(subject.new(hexdigest: 'sha1').sanitize_hexdigest("foo")).to eq "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33"
    end

    it 'hexdigests sha2-256' do
      expect(subject.new(hexdigest: 'sha256').sanitize_hexdigest("foo")).to eq "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae"
    end

    it 'hexdigests sha2-384' do
      expect(subject.new(hexdigest: 'sha384').sanitize_hexdigest("foo")).to eq "98c11ffdfdd540676b1a137cb1a22b2a70350c9a44171d6b1180c6be5cbb2ee3f79d532c8a1dd9ef2e8e08e752a3babb"
    end

    it 'hexdigests sha2-512' do
      expect(subject.new(hexdigest: 'sha512').sanitize_hexdigest("foo")).to eq "f7fbba6e0636f890e56fbbf3283e524c6fa3204ae298382d624741d0dc6638326e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7"
    end

    it 'hexdigest raises with unknown digester' do
      expect{subject.new(hexdigest: 'foo').sanitize_hexdigest("foo")}.to raise_error(TypeError)
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


