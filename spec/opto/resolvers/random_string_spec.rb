require_relative '../../spec_helper'

describe Opto::Resolvers::RandomString do

  describe '#resolve' do
    let(:subject) { described_class }

    it 'generates a random string of :lenght' do
      expect(subject.new(length: 10).resolve.length).to be 10
      expect(subject.new(15).resolve.length).to be 15
    end

    it 'can switch charsets' do
      expect(subject.new(length: 200, charset: :hex).resolve).to match(/\A[a-f0-9]{200}\z/)
    end

    it 'raises if length is not set' do
      expect{subject.new({}).resolve}.to raise_error(ArgumentError)
    end

    it 'raises if trying to create invalid base64' do
      expect{subject.new(charset: :base64, length: 10).resolve}.to raise_error(ArgumentError)
      expect{subject.new(charset: :base64, length: 12).resolve}.not_to raise_error
    end
  end

  describe '#charset' do
    let(:subject) { described_class.new }

    it 'knows :numbers' do
      expect(subject.charset(:numbers).all? {|n| n.match(/\A[0-9]\z/) }).to be_truthy
    end

    it 'knows :letters' do
      expect(subject.charset(:letters).all? {|n| n.match(/\A[a-zA-Z]\z/) }).to be_truthy
    end

    it 'knows :upcase' do
      expect(subject.charset(:upcase).all? {|n| n.match(/\A[A-Z]\z/) }).to be_truthy
    end

    it 'knows :downcase' do
      expect(subject.charset(:downcase).all? {|n| n.match(/\A[a-z]\z/) }).to be_truthy
    end

    it 'knows :alphanumeric' do
      expect(subject.charset(:alphanumeric).all? {|n| n.match(/\A[A-Za-z0-9]\z/) }).to be_truthy
    end

    it 'knows :hex' do
      expect(subject.charset(:hex).all? {|n| n.match(/\A[a-f0-9]\z/) }).to be_truthy
    end

    it 'knows :hex_upcase' do
      expect(subject.charset(:hex_upcase).all? {|n| n.match(/\A[A-F0-9]\z/) }).to be_truthy
    end

    it 'knows :base64' do
      expect(subject.charset(:base64).all? {|n| n.match(/\A[a-zA-Z0-9\+\/]\z/) }).to be_truthy
    end

    it 'knows :ascii_printable' do
      expect(subject.charset(:ascii_printable).all? {|n| n.match(/\A\S\z/) }).to be_truthy
    end

    it 'knows char ranges' do
      expect(subject.charset('a-e')).to eq ['a', 'b', 'c', 'd', 'e']
    end

    it 'knows numeric ranges' do
      expect(subject.charset('0-3')).to eq ['0', '1', '2', '3']
    end

    it 'uses the :charset as charset if the charset is unknown' do
      expect(['a','b','c','d'].all? { |c| subject.charset('abcd').include?(c) }).to be_truthy
      expect(['a','b','c','d'].all? { |c| subject.charset('abc').include?(c) }).to be_falsey
    end
  end
end

