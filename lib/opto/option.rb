require_relative 'type'
require_relative 'resolver'
require_relative 'setter'
require_relative 'extensions/snake_case'
require_relative 'extensions/hash_string_or_symbol_key'

module Opto
  # What is an option? It's like a variable that has a value, which can be validated or
  # manipulated on creation. The value can be resolved from a number of origins, such as
  # an environment variable or random string generator.
  class Option

    using Opto::Extension::SnakeCase
    using Opto::Extension::HashStringOrSymbolKey

    attr_accessor :type
    attr_accessor :name
    attr_accessor :label
    attr_accessor :description
    attr_accessor :required
    attr_accessor :default
    attr_reader   :from
    attr_reader   :to
    attr_reader   :group
    attr_reader   :skip_if
    attr_reader   :only_if
    attr_reader   :initial_value
    attr_reader   :type_options

    # Initialize an instance of Opto::Option
    # @param [Hash] options
    #   @option [String] :name Option name
    #   @option [String,Symbol] :type Option type, such as :integer, :string, :boolean, :enum
    #   @option [String] :label A label for this field, to be used in for example an interactive prompt
    #   @option [String] :description Same as label, but more detailed
    #   @option [*] :default Default value for option
    #   @option [String,Symbol,Array<String,Symbol,Hash>,Hash] :from Resolver origins
    #   @option [String,Symbol,Array<String,Symbol,Hash>,Hash] :to Setter targets
    #   @option [String,Symbol,Array<String,Symbol,Hash>,Hash] :skip_if Conditionals that define if this option should be skipped
    #   @option [String,Symbol,Array<String,Symbol,Hash>,Hash] :only_if Conditionals that define if this option should be included
    #   @option [Opto::Group] :group Parent group reference
    #   @option [...] Type definition options, such as { min_length: 3, strip: true }
    #
    # @example Create an option
    #   Opto::Option.new(
    #     name: 'cat_name',
    #     type: 'string',
    #     label: 'Name of your Cat',
    #     required: true,
    #     description: 'Enter a name for your cat',
    #     from:
    #       env: 'CAT_NAME'
    #     only_if:
    #       pet: 'cat'
    #     min_length: 2
    #     max_length: 20
    #   )
    #
    # @example Create a random string
    #   Opto::Option.new(
    #     name: 'random_string',
    #     type: :string,
    #     from:
    #       random_string:
    #         length: 20
    #         charset: ascii_printable
    #   )
    def initialize(options = {})
      opts           = options.dup

      @group         = opts.delete(:group)
      if @group && @group.defaults
        opts = @group.defaults.reject{|k,_| [:from, :to].include?(k)}.merge(opts)
      end

      @name          = opts.delete(:name).to_s

      type           = opts.delete(:type)
      @type          = type.to_s.snakecase unless type.nil?

      @label         = opts.delete(:label) || @name
      @description   = opts.delete(:description)
      @default       = opts.delete(:default)
      val            = opts.delete(:value)
      @skip_if       = opts.delete(:skip_if)
      @only_if       = opts.delete(:only_if)
      @from          = normalize_from_to(opts.delete(:from))
      @to            = normalize_from_to(opts.delete(:to))
      validations    = opts.delete(:validate).to_h
      transforms     = opts.delete(:transform)
      transforms     =  case transforms
                        when NilClass then {}
                        when Hash then transforms
                        when Array then
                          transforms.each_with_object({}) { |t, hash| hash[t] = true }
                        else
                          raise TypeError, 'Transform has to be a hash or an array'
                        end
      @type_options  = opts.merge(validations).merge(transforms)

      set_initial(val) if val
      deep_merge_defaults
    end

    def deep_merge_defaults
      return nil unless group && group.defaults
      if group.defaults[:from]
        normalize_from_to(group.defaults[:from]).each do |k,v|
          from[k] ||= v
        end
      end
      if group.defaults[:to]
        normalize_from_to(group.defaults[:to]).each do |k,v|
          to[k] ||= v
        end
      end
    end

    # Hash representation of Opto::Option. Can be passed back to Opto::Option.new
    # @param [Boolean] with_errors Include possible validation errors hash
    # @param [Boolean] with_value Include current value
    # @return [Hash]
    def to_h(with_errors: false, with_value: true)
      hash = {
        name: name,
        label: label,
        type: type,
        description: description,
        default: default,
        from: from.reject { |k,_| k == :default},
        to: to
      }.merge(type_options).reject { |_,v| v.nil? }
      hash[:skip_if] = skip_if if skip_if
      hash[:only_if] = only_if if only_if
      hash[:errors]  = errors  if with_errors
      hash[:value]   = value   if with_value
      hash
    end

    # Set option value. Also aliased as #value=
    # @param value
    def set(value)
      @value = handler.sanitize(value)
      validate
      @value
    end

    alias_method :value=, :set

    # Returns true if this field should not be processed because of the conditionals
    # @return [Boolean]
    def skip?
      return false if group.nil?
      return true if group.any_true?(skip_if)
      return true unless group.all_true?(only_if)
      false
    end

    # Get a value of another Opto::Group member
    # @param [String] option_name
    def value_of(option_name)
      return value if option_name == self.name
      group.nil? ? nil : group.value_of(option_name)
    end

    # Run validators
    # @raise [TypeError, ArgumentError]
    def validate
      handler.validate(@value)
    rescue StandardError => ex
      raise ex, "Validation for #{name} : #{ex.message}"
    end

    # Access the Opto::Type handler for this option
    # @return [Opto::Type]
    def handler
      @handler ||= Type.for(type).new(type_options)
    rescue StandardError => ex
      raise ex, "#{name}: #{ex.message}"
    end

    # The value of this option. Will try to run resolvers.
    # @return option_value
    def value
      return @value unless @value.nil?
      return nil if skip?
      set(resolve)
      @value
    end

    # Accessor to defined resolvers for this option.
    # @return [Array<Opto::Resolver>]
    def resolvers
      @resolvers ||= from.merge(default: self).map { |origin, hint| Resolver.for(origin).new(hint, self) }
    end

    def setters
      @setters ||= to.map { |target, hint| Setter.for(target).new(hint, self) }
    end

    # True if this field is defined as required: true
    # @return [Boolean]
    def required?
      handler.required?
    end

    # Run resolvers
    # @raise [TypeError, ArgumentError]
    def resolve
      resolvers.each do |resolver|
        begin
          result = resolver.try_resolve
        rescue StandardError => ex
          raise ex, "Resolver '#{resolver.origin}' for '#{name}' : #{ex.message}"
        end
        unless result.nil?
          @origin = resolver.origin
          return result
        end
      end
      nil
    end

    # Run setters
    def output
      setters.each do |setter|
        begin
          setter.respond_to?(:before) && setter.before(self)
          setter.set(value)
          setter.respond_to?(:after)  && setter.after(self)
        rescue StandardError => ex
          raise ex, "Setter '#{setter.target}' for '#{name}' : #{ex.message}"
        end
      end
    end

    # True if value is valid
    # @return [Boolean]
    def valid?
      return true if skip?
      handler.valid?(value)
    end

    def true?
      handler.truthy?(value)
    end

    # Validation errors
    # @return [Hash]
    def errors
      handler.errors
    end

    def normalize_from_to(inputs)
      case inputs
      when ::Array
        case inputs.first
        when String, Symbol
          inputs.each_with_object({}) { |o, hash| hash[o.to_s.snakecase.to_sym] = name }
        when Hash
          inputs.each_with_object({}) { |o, hash| o.each { |k,v| hash[k.to_s.snakecase.to_sym] = v } }
        when NilClass
          {}
        else
          raise TypeError, "Invalid format #{inputs.inspect}"
        end
      when Hash
        inputs.each_with_object({}) { |(k, v), hash| hash[k.to_s.snakecase.to_sym] = v }
      when String, Symbol
        { inputs.to_s.snakecase.to_sym => name }
      when NilClass
        {}
      else
        raise TypeError, "Invalid format #{inputs.inspect}"
      end
    end

    private

    def set_initial(value)
      return nil if value.nil?
      @origin = :initial
      set(value)
    end
  end
end
