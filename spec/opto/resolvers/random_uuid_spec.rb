require_relative '../../spec_helper'

describe Opto::Resolvers::RandomUuid do

  describe '#resolve' do
    let(:subject) { described_class.new }

    it 'generates a random uuid' do
      expect(subject.resolve).to match(/\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/)
    end
  end
end
