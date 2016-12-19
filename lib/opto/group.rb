require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

if RUBY_VERSION < '2.1'
  using Opto::Extension::SnakeCase
  using Opto::Extension::HashStringOrSymbolKey
end

module Opto
  # A group of Opto::Option instances. Members of Groups can see their relatives
  # and their values. Such as `option.value_of('another_option')`
  #
  # Most Array instance methods are delegated, such as .map, .each, .find etc.
  class Group

    using Opto::Extension::HashStringOrSymbolKey unless RUBY_VERSION < '2.1'

    attr_reader :options, :defaults

    extend Forwardable

    # Initialize a new Option Group. You can also pass in :defaults.
    #
    # @param [Array<Hash,Opto::Option>,Hash,NilClass] opts An array of Option definition hashes or Option objects or a hash like { var_name: { opts } }.
    # @return [Opto::Group]
    def initialize(*options)
      if options.size > 0
        if options.last.kind_of?(Hash) && options.last[:defaults]
          @defaults = options.pop[:defaults]
        end
        @options =
          case options.first
          when NilClass
            []
          when Hash
            options.first.map {|k,v| Option.new({name: k.to_s, group: self}.merge(v))}
          when ::Array
            options.first.map {|opt| opt.kind_of?(Opto::Option) ? opt : Option.new(opt.merge(group: self)) }
          else
            raise TypeError, "Invalid type #{options.first.class} for Opto::Group.new"
          end
      else
        @options = []
      end

    end

    # Are all options valid? (Option value passes validation)
    # @return [Boolean]
    def valid?
      options.all? {|o| o.valid? }
    end

    # Collect validation errors from members
    # @return [Hash] { option_name => { validator_name => "Too short" } }
    def errors
      Hash[*options_with_errors.flat_map {|o| [o.name, o.errors] }]
    end

    # Enumerate over all the options that are not valid
    # @return [Array]
    def options_with_errors
      options.reject(&:valid?)
    end

    # Convert Group to an Array of Hashes (by calling .to_h on each member)
    # @return [Array<Hash>]
    def to_a(with_errors: false, with_value: false)
      options.map {|opt| opt.to_h(with_errors: with_errors, with_value: with_value) }
    end

    # Convert a Group to a hash that has { option_name => option_value }
    # @return [Hash]
    def to_h(values_only: false, with_values: false, with_errors: false)
      if values_only
        Hash[*options.flat_map {|opt| [opt.name, opt.value]}]
      else
        Hash[*options.flat_map {|opt| [opt.name, opt.to_h(with_value: with_values, with_errors: with_errors).reject {|k,_| k==:name}]}]
      end
    end

    # Runs outputters for all valid non-skipped options
    def run
      options.reject(&:skip?).select(&:valid?).each(&:output)
    end

    # Initialize a new Option to this group. Takes the same arguments as Opto::Option
    # @param [Hash] option_definition
    # @return [Opto::Option]
    def build_option(args={})
      options << Option.new(args.merge(group: self))
      options.last
    end

    # Find a member by name
    # @param [String] option_name
    # @return [Opto::Option]
    def option(option_name)
      options.find { |opt| opt.name == option_name }
    end

    # Get a value of a member by option name
    # @param [String] option_name
    # @return [option_value, NilClass]
    def value_of(option_name)
      opt = option(option_name)
      opt.nil? ? nil : opt.value
    end

    def_delegators :@options, *(::Array.instance_methods - [:__send__, :object_id, :to_h, :to_a, :is_a?, :kind_of?, :instance_of?])
  end
end
