require_relative '../../spec_helper'

describe Opto::Resolvers::Variable do

  describe '#resolve' do
    let(:subject) { described_class }

    it 'returns values from other options' do
      group = Opto::Group.new
      opt_1 = group.build_option(type: :string, name: 'foo', value: 'hello')
      opt_2 = group.build_option(type: :string, name: 'bar', from: { variable: 'foo' })
      expect(opt_2.value).to eq 'hello'
    end
  end
end
