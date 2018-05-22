require_relative '../../spec_helper'

describe Opto::Resolvers::Interpolate do

  describe '#resolve' do
    let(:subject) { described_class }

    it 'raises if hint is not a string' do
      expect{subject.new(nil).resolve}.to raise_error(TypeError)
    end

    it 'interpolates values from other options into a string' do
      group = Opto::Group.new
      opt_1 = group.build_option(type: :string, name: 'hi', value: 'hello')
      opt_2 = group.build_option(type: :string, name: 'place', value: 'world')
      opt_3 = group.build_option(type: :string, name: 'greeting', from: { interpolate: '$hi ${place}'})
      expect(opt_3.value).to eq 'hello world'
    end

    it 'interpolates values from sub-options into a string' do
      group = Opto::Group.new(
        'foo' => {
          type: :group,
          value: {
            'bar' => {
              type: :string,
              value: 'hello'
            }
          }
        },
        'baz' => {
          type: :string,
          from: {
            interpolate: "${foo.bar}, world"
          }
        }
      )

      expect(group.option('baz').value).to eq "hello, world"
    end
  end
end


