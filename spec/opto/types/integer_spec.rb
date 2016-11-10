require_relative '../../spec_helper'

describe Opto::Types::Integer do
  let(:subject) { described_class.new(min: 2, max: 3) }

  context 'sanitize' do
    it 'converts a string to integer' do
      expect(subject.sanitize_to_i("2")).to eq 2
    end
  end

  context 'validate' do
    it 'gives a validation error when number is below the defined :min' do
      expect(subject.validate_min(1)).to match(/Too small/)
    end

    it 'gives a validation error when number is above the defined :max' do
      expect(subject.validate_max(4)).to match(/Too large/)
    end

    it 'gives no error when number is in range' do
      expect(subject.validate_min(3)).to be_nil
      expect(subject.validate_max(3)).to be_nil
    end
  end
end
