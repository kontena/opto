require_relative '../../spec_helper'

describe Opto::Resolvers::File do

  describe '#resolve' do
    let(:subject) { described_class }

    it 'reads a file' do
      expect(File).to receive(:read).with('/tmp/foo').and_return("BNUB!")
      expect(subject.new('/tmp/foo').resolve).to eq 'BNUB!'
    end

    it 'raises if path is not set' do
      expect{subject.new(nil).resolve}.to raise_error(ArgumentError)
    end

    it 'raises if file does not exist' do
      expect {
        subject.new('/tmp/foo').resolve
      }.to raise_error(Errno::ENOENT)
    end

    it 'returns nil if file does not exist and ignore_errors is set' do
      hint = {
        path: '/tmp/foo',
        ignore_errors: true
      }
      expect(subject.new(hint).resolve).to be_nil
    end
  end
end

