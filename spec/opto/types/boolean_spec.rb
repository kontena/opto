require_relative '../../spec_helper'

describe Opto::Types::Boolean do
  let(:subject) { described_class }

  context 'sanitize' do
    it 'converts a string or number to integer' do
      expect(subject.new.sanitize_to_bool("true")).to be_truthy
      expect(subject.new.sanitize_to_bool(" 1")).to be_truthy
      expect(subject.new.sanitize_to_bool(1)).to be_truthy
      expect(subject.new.sanitize_to_bool("yes")).to be_truthy
      expect(subject.new.sanitize_to_bool("fofofoo")).to be_falsey
      expect(subject.new(truthy: ['fofofoo']).sanitize_to_bool("fofofoo")).to be_truthy
    end

    it 'makes a nil become true or false' do
      expect(subject.new(nil_is: false).sanitize_to_bool(nil)).to be_kind_of(FalseClass)
      expect(subject.new(nil_is: true).sanitize_to_bool(nil)).to be_kind_of(TrueClass)
    end

    it 'makes a blank become true or false' do
      expect(subject.new(blank_is: false).sanitize_to_bool(" \n")).to be_kind_of(FalseClass)
      expect(subject.new(blank_is: true).sanitize_to_bool("")).to be_kind_of(TrueClass)
    end

    it 'can output a string, integer or boolean' do
      expect(subject.new(as: :string).sanitize_output(true)).to eq 'true'
      expect(subject.new(as: :string).sanitize_output(false)).to eq 'false'
      expect(subject.new(as: :string, true: "hello", false: "bye").sanitize_output(false)).to eq 'bye'
      expect(subject.new(as: :string, true: "hello", false: "bye").sanitize_output(true)).to eq 'hello'
      expect(subject.new(as: :integer).sanitize_output(true)).to eq 1
      expect(subject.new(as: :integer).sanitize_output(false)).to eq 0
      expect(subject.new(as: :boolean).sanitize_output(true)).to be_truthy
      expect(subject.new(as: :boolean).sanitize_output(false)).to be_falsey
    end
  end
end

