require_relative '../../spec_helper'

describe Opto::Resolvers::Condition do

  describe '#resolve' do
    let(:subject) { described_class }

    let(:group) { Opto::Group.new }

    before(:each) do
      group.build_option(type: 'string', name: 'str', value: 'foo')
      group.build_option(type: 'boolean', name: 'bool', value: true)
      group.build_option(type: 'integer', name: 'int', value: 4)
    end

    it 'does if/elsif/else' do
      opt = group.build_option(
        type: 'string',
        name: 'opt',
        from: {
          condition: [
            { if: { str: "foo" },
              then: "foofoo"
            },
            { elsif: { str: "bar" },
              then: "barbar"
            },
            { else: "foobar" }
          ]
        }
      )

      group.option('str').set('foo')
      expect(opt.resolve).to eq 'foofoo'
      group.option('str').set('bar')
      expect(opt.resolve).to eq 'barbar'
      group.option('str').set('baz')
      expect(opt.resolve).to eq 'foobar'
    end

    it 'does if/elsif/else with complex conditions' do
      opt = group.build_option(
        type: 'string',
        name: 'opt',
        from: {
          condition: [
            { if: { str: { start_with: "foo", end_with: "doo", any_of: "foo,foovoodoo", ne: "foodoodoo", contain: "oo", eq: 'foovoodoo' }, int: { gt: 5, lt: 10, lte: 9, gte: 6, any_of: [6,7,8,9] } },
              then: "foofoo"
            },
            { else: "foobar" }
          ]
        }
      )

      group.option('str').set('foo')
      expect(opt.resolve).to eq 'foobar'
      group.option('int').set(5)
      expect(opt.resolve).to eq 'foobar'
      group.option('int').set(10)
      expect(opt.resolve).to eq 'foobar'
      group.option('int').set(9)
      expect(opt.resolve).to eq 'foobar'
      group.option('str').set("foovoodoo")
      group.option('int').set(5)
      expect(opt.resolve).to eq 'foobar'
      group.option('int').set(10)
      expect(opt.resolve).to eq 'foobar'
      group.option('int').set(9)
      expect(opt.resolve).to eq 'foofoo'
      group.option('str').set("foodoodoo")
      expect(opt.resolve).to eq 'foobar'
    end

    it 'raises if hint is not an array' do
      expect{subject.new(foo: :bar).resolve}.to raise_error(TypeError)
      expect{subject.new(:foo).resolve}.to raise_error(TypeError)
      expect{subject.new(1).resolve}.to raise_error(TypeError)
    end

    it 'raises if hint is not an array of hashes' do
      expect{subject.new([:foo, :bar]).resolve}.to raise_error(TypeError)
      expect{subject.new([:foo, {foo: :bar}]).resolve}.to raise_error(TypeError)
    end

  end
end



