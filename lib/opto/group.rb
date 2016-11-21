module Opto
  # A group of Opto::Option instances. Members of Groups can see their relatives
  # and their values. Such as `option.value_of('another_option')`
  #
  # Most Array instance methods are delegated, such as .map, .each, .find etc.
  class Group

    attr_reader :options

    extend Forwardable

    # Initialize a new Option Group.
    # @param [Array<Hash,Opto::Option>] opts An array of Option definition hashes or Option objects.
    # @return [Opto::Group]
    def initialize(opts = [])
      @options = opts.map {|opt| opt.kind_of?(Opto::Option) ? opt : Option.new(opt.merge(group: self)) }
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
    def to_a
      options.map(&:to_h)
    end

    # Convert a Group to a hash that has { option_name => option_value }
    # @return [Hash]
    def to_h
      Hash[*options.flat_map {|opt| [opt.name, opt.value]}]
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
      options.find { |opt| opt.name == option_name.downcase }
    end

    # Get a value of a member by option name
    # @param [String] option_name
    # @return [option_value, NilClass]
    def value_of(option_name)
      opt = option(option_name)
      opt.nil? ? nil : opt.value
    end

    def_delegators :@options, *(Array.instance_methods - [:__send__, :object_id, :to_h, :to_a, :is_a?, :kind_of?, :instance_of?])
  end
end
