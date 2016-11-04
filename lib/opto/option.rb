require_relative 'type'
require_relative 'resolver'

module Opto
  class Option

    attr_accessor :type
    attr_accessor :name
    attr_accessor :description
    attr_accessor :required
    attr_accessor :type_options
    attr_accessor :default
    attr_accessor :resolvers
    attr_reader   :handler
    attr_reader   :errors


    def initialize(options = {})
      opts = options.dup
      @type = require_and_delete_option(opts, :type)
      @name = require_and_delete_option(opts, :name)
      @description = opts.delete(:description)
      @required = opts.delete(:required) || false
      @default = opts.delete(:default)
      val = opts.delete(:value)
      @handler = Type.handler_for(type).new(self, opts)
      @resolvers = []
      @resolvers << Resolver.resolver(:default).new(self) if @default
      @errors = {}
      self.value = val if val
    end

    def require_and_delete_option(options, option_name)
      raise ArgumentError, "Missing required option :#{option_name}" if options[option_name].nil?
      options.delete(option_name)
    end

    def required?
      @required
    end

    def value=(value)
      @value = value
      @errors = handler.validate
      @value
    end

    def resolve
      resolvers.each do |resolver|
        result = resolver.resolve
        return result if result
      end
      nil
    end

    def value
      return @value if @value
      self.value = resolve
      @value
    end

    def valid?
      errors.empty?
    end
  end
end
