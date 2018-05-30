require_relative '../../spec_helper'

describe Opto::Types::Group do
  let(:subject) { described_class }

  it 'should have an empty group initially' do
    group = Opto::Option.new(type: :group, name: 'foogroup')
    expect(group.value).to be_kind_of(Opto::Group)
  end

  it 'should allow access to sub variables' do
    group = Opto::Option.new(type: :group, name: 'foogroup', value: { 'abc' => { type: :string, value: '123' } })
    expect(group.value_of('foogroup').value_of('abc')).to eq '123'
  end

  it 'should accept value in variables-option' do
    group = Opto::Option.new(type: :group, name: 'foogroup', variables: { 'abc' => { type: :string, value: '123' } })
    expect(group.value_of('foogroup').value_of('abc')).to eq '123'
  end

  describe 'to_h' do
    it 'should hashify the subgroup values as nested hash using values_only: true' do
      group = Opto::Group.new({'foo' => { type: :group, value: { 'abc' => { type: :string, value: '123' }}}})
      expect(group.to_h(values_only: true)).to match hash_including(
        'foo' => hash_including(
          'abc' => '123'
        )
      )
    end

    it 'should hashify the subgroup values as nested variables definition' do
      group = Opto::Group.new({'foo' => { type: :group, value: { 'abc' => { type: :string, value: '123' }}}})
      expect(group.to_h(with_values: true)).to match hash_including(
        'foo' => hash_including(
          type: 'group',
          value: hash_including(
            'abc' => hash_including(
              type: 'string',
              value: '123'
            )
          )
        )
      )
    end
  end
end
