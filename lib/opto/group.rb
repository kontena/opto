require 'opto/option'
require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

module Opto
  # A group of Opto::Option instances. Members of Groups can see their relatives
  # and their values. Such as `option.value_of('another_option')`
  #
  # Most Array instance methods are delegated, such as .map, .each, .find etc.
  class Group

    using Opto::Extension::HashStringOrSymbolKey

    extend Forwardable

    # Initialize a new Option Group. You can also pass in :defaults.
    #
    # @param [Array<Hash,Opto::Option>,Hash,NilClass] opts An array of Option definition hashes or Option objects or a hash like { var_name: { opts } }.
    # @return [Opto::Group]
    def initialize(*opts)
      case opts.first
      when NilClass
      when Hash
        defaults.merge!(opts.first.delete(:defaults)) if opts.first.key?(:defaults)
        setters.merge!(opts.first.delete(:setters)) if opts.first.key?(:setters)
        resolvers.merge!(opts.first.delete(:resolvers)) if opts.first.key?(:resolvers)
        options.concat(opts.first.map {|k,v| Option.new({name: k.to_s, group: self}.merge(v))})
      when ::Array
        if opts.last.is_a?(Hash) && !opts.last.key?(:type)
          opts.pop.tap do |settings|
            defaults.merge!(settings[:defaults]) if settings.key?(:defaults)
            setters.merge!(settings[:setters]) if settings.key?(:setters)
            resolvers.merge!(settings[:resolvers]) if settings.key?(:resolvers)
          end
        end
        if opts.first.kind_of?(Array)
          options.concat(opts.first.map { |opt| opt.kind_of?(Opto::Option) ? opt : Option.new(opt.merge(group: self)) })
        end
      else
        raise TypeError, "Invalid type #{opts.class} for Opto::Group.new"
      end
    end

    def options
      @options ||= []
    end

    def setters
      @setters ||= {}
    end

    def resolvers
      @resolvers ||= {}
    end

    def defaults
      @defaults ||= {}
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

    def any_true?(conditions)
      normalize_ifs(conditions).any? { |s| s.call(self) == true }
    end

    def all_true?(conditions)
      normalize_ifs(conditions).all? { |s| s.call(self) == true }
    end

    def normalize_ifs(ifs)
      case ifs
      when NilClass
        []
      when ::Array
        ifs.map do |iff|
          lambda { |grp| grp.option(iff).true?  }
        end
      when Hash
        ifs.each_with_object([]) do |(k, v), arr|
          if v.kind_of?(Hash)
            if v.has_key?(:lt)
              arr << lambda { |grp| grp.value_of(k.to_s) < v[:lt] }
            end

            if v.has_key?(:lte)
              arr << lambda { |grp| grp.value_of(k.to_s) <= v[:lte] }
            end

            if v.has_key?(:gt)
              arr << lambda { |grp| grp.value_of(k.to_s) > v[:gt] }
            end

            if v.has_key?(:gte)
              arr << lambda { |grp| grp.value_of(k.to_s) > v[:gte] }
            end

            if v.has_key?(:eq)
              arr << lambda { |grp| grp.value_of(k.to_s) == v[:eq] }
            end

            if v.has_key?(:ne)
              arr << lambda { |grp| grp.value_of(k.to_s) != v[:ne] }
            end

            if v.has_key?(:start_with)
              arr << lambda { |grp| grp.value_of(k.to_s).to_s.start_with?(v[:start_with]) }
            end

            if v.has_key?(:end_with)
              arr << lambda { |grp| grp.value_of(k.to_s).to_s.end_with?(v[:end_with]) }
            end

            if v.has_key?(:contain)
              arr << lambda { |grp| grp.value_of(k.to_s).kind_of?(::Array) ? grp.value_of(k.to_s).include?(v[:contain]) : grp.value_of(k.to_s).to_s.include?(v[:contain]) }
            end

            if v.has_key?(:any_of)
              arr << lambda do |grp|
                if v[:any_of].kind_of?(String)
                  arr = v[:any_of].split(",")
                elsif v[:any_of].kind_of?(::Array)
                  arr = v[:any_of]
                else
                  raise TypeError, "Invalid list for 'any_of'. Expected: Array or a comma separated string"
                end
                arr.include?(grp.value_of(k.to_s))
              end
            end
          else
            arr << lambda { |grp| grp.value_of(k.to_s) == v }
          end
        end
      when String, Symbol
        normalize_ifs([ifs])
      else
        raise TypeError, "Invalid syntax for conditional"
      end
    end

    def_delegators :options, *(::Array.instance_methods - [:__send__, :object_id, :to_h, :to_a, :is_a?, :kind_of?, :instance_of?, :self, :inspect, :nil?])
  end
end
