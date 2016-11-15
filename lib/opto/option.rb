require_relative 'type'
require_relative 'resolver'
require_relative 'extensions/snake_case'
require_relative 'extensions/hash_string_or_symbol_key'

module Opto
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
    attr_reader   :group
    attr_reader   :skip_if
    attr_reader   :only_if
    attr_reader   :initial_value
    attr_reader   :type_options

    def initialize(options = {})
      opts           = options.dup
      type           = opts.delete(:type)
      @type          = type.to_s.snakecase unless type.nil?
      @name          = opts.delete(:name).to_s.downcase
      @label         = opts.delete(:label) || @name
      @description   = opts.delete(:description)
      @default       = opts.delete(:default)
      val            = opts.delete(:value)
      @from          = { default: self }.merge(normalize_origins(opts.delete(:from)))
      @skip_if       = opts.delete(:skip_if)
      @only_if       = opts.delete(:only_if)
      @skip_lambdas  = normalize_ifs(@skip_if)
      @only_lambdas  = normalize_ifs(@only_if)
      @group         = opts.delete(:group)
      @type_options  = opts

      val ? set_initial(val) : set(resolve)
    end

    def to_h(with_errors: false, with_value: true)
      hash = {
        name: name,
        label: label,
        type: type,
        description: description,
        default: default,
        from: from.reject { |k,_| k == :default},
      }.merge(type_options).reject { |_,v| v.nil? }
      hash[:skip_if] = skip_if if skip_if
      hash[:only_if] = only_if if only_if
      hash[:errors]  = errors  if with_errors
      hash[:value]   = value   if with_value
      hash
    end


    def set(value)
      @value = handler.sanitize(value)
      validate
      @value
    end

    alias_method :value=, :set

    def skip?
      return true if     @skip_lambdas.any? { |s| s.call(self) }
      return true unless @only_lambdas.all? { |s| s.call(self) }
      false
    end

    def value_of(option_name)
      group.nil? ? nil : group.value_of(option_name)
    end

    def validate
      handler.validate(@value)
    rescue StandardError => ex
      raise ex, "Validation for #{name} : #{ex.message}"
    end

    def handler
      @handler ||= Type.for(type).new(type_options)
    end

    def value
      return @value unless @value.nil?
      unless @tried_resolve
        @tried_resolve = true
        set(resolve)
      end
      @value
    end

    def resolvers
      @resolvers ||= from.map { |origin, hint| Resolver.for(origin).new(hint, self) }
    end

    def normalize_ifs(ifs)
      case ifs
      when NilClass
        []
      when Array
        ifs.map do |iff|
          lambda { |opt| !opt.value_of(iff).nil? }
        end
      when Hash
        ifs.each_with_object([]) do |(k, v), arr|
          arr << lambda { |opt| opt.value_of(k.to_s) == v }
        end
      when String, Symbol
        [lambda { |opt| !opt.value_of(ifs.to_s).nil? }]
      else
        raise TypeError, "Invalid syntax for if"
      end
    end

    def normalize_origins(origins)
      case origins
      when Array
        case origins.first
        when String, Symbol
          origins.each_with_object({}) { |o, hash| hash[o.to_s.snakecase.to_sym] = nil }
        when Hash
          origins.each_with_object({}) { |o, hash| o.each { |k,v| hash[k.to_s.snakecase.to_sym] = v } }
        when NilClass
          {}
        else
          raise TypeError, "Invalid format for value sources"
        end
      when Hash
        origins.each_with_object({}) { |(k, v), hash| hash[k.to_s.snakecase.to_sym] = v }
      when String, Symbol
        { origins.to_s.snakecase.to_sym => nil }
      when NilClass
        {}
      else
        raise TypeError, "Invalid format for value sources"
      end
    end

    def required?
      handler.required?
    end

    def resolve
      resolvers.each do |resolver|
        begin
          result = resolver.resolve
        rescue StandardError => ex
          raise ex, "Resolver '#{resolver.origin}' for '#{name}' : #{ex.message}"
        end
        if result
          @origin = resolver.origin
          return result
        end
      end
      nil
    end

    def valid?
      handler.valid?(value)
    end

    def errors
      handler.errors
    end
    
    private

    def set_initial(value)
      return nil if value.nil?
      @origin = :initial
      set(value)
    end

  end
end
