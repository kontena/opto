require_relative '../../spec_helper'

describe Opto::Types::Integer do
  let(:klass) { described_class }
  let(:subject) { klass.new(min: 2, max: 3) }

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

  context 'evaluation' do
    it 'can perform simple calculations' do
      opt = Opto::Option.new(type: :integer, value: "3*(1+2)", name: 'foo')
      expect(opt.value).to eq 9
    end

    it 'can be made to not eval' do
      opt = Opto::Option.new(type: :integer, value: "3*(1+2)", eval: false, name: 'foo')
      expect(opt.value).to eq 3 # "3*(1+2)".to_i => 3
    end

    it 'can perform simple calculations with variables' do
      group = Opto::Group.new
      opt_1 = group.build_option(type: :string, value: "4", name: 'foo_string')
      opt_2 = group.build_option(type: :integer, value: 5, name: 'foo_int')
      opt_3 = group.build_option(type: :integer, value: "${foo_string}+${foo_int}+1", name: 'foobar_calc')
      expect(opt_3.value).to eq 10
    end

    it 'raises if option is not in a group' do
      expect{Opto::Option.new(type: :integer, value: "${foo_string}", name: 'foobar_int')}.to raise_error(RuntimeError)
    end

    it 'raises if referenced option is nil' do
      group = Opto::Group.new
      opt_1 = group.build_option(type: :string, value: nil, name: 'foo_string')
      expect{group.build_option(type: :integer, value: "${foo_string}+1", name: 'foobar_calc')}.to raise_error(RuntimeError)
    end

    it 'raises if it doesnt look like a calculation' do
      group = Opto::Group.new
      opt_1 = group.build_option(type: :string, value: "gnah", name: 'foo_string')
      opt_2 = group.build_option(type: :integer, value: 5, name: 'foo_int')
      expect{group.build_option(type: :integer, value: "${foo_string}+${foo_int}+1", name: 'foobar_calc')}.to raise_error(RuntimeError)
    end
  end
end
