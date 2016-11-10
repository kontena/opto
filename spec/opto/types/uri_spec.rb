require_relative '../../spec_helper'

describe Opto::Types::Uri do
  let(:subject) { described_class }

  context 'validate' do
    it 'allows any scheme when schemes empty' do
      expect(subject.new(schemes: nil).validate_scheme('xxx://foofoo')).to be_nil
    end

    it 'allows only defined schemes' do
      expect(subject.new(schemes: ['http']).validate_scheme('xxx://foofoo')).to match(/not allowed/)
      expect(subject.new(schemes: ['http', 'https']).validate_scheme('https://foofoo')).to be_nil
    end

  end
end

