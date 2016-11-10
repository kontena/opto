require_relative 'extensions/snake_case'
require_relative 'extensions/hash_string_or_symbol_key'

module Opto
  class Type
    GLOBAL_OPTIONS = {
      required: true
    }

    attr_accessor :options

    using Opto::Extension::SnakeCase
    using Opto::Extension::HashStringOrSymbolKey

    class << self
      def inherited(where)
        types[where.type] = where
      end

      def types
        @types ||= {}
      end

      def type
        name.to_s.split('::').last.snakecase.to_sym
      end

      def for(type_name)
        raise NameError, "No handler for type #{type_name}" unless types[type_name]
        types[type_name]
      end

      def validators
        @validators ||= []
      end

      def validator(name, &block)
        raise TypeError, "Block required" unless block_given?
        validators << define_method("validate_#{name}", block)
      end

      def sanitizers
        @sanitizers ||= []
      end

      def sanitizer(name, &block)
        raise TypeError, "Block required" unless block_given?
        sanitizers << define_method("sanitize_#{name}", &block)
      end
    end

    validator :in do |value|
      return true unless options[:in]
      options[:in].each do |val|
        return true if value === val
      end
      "Value #{value} not in #{options[:in].join(', ')}"
    end

    def initialize(options = {})
      @options = Type::GLOBAL_OPTIONS.merge(self.class.const_defined?(:OPTIONS) ? self.class.const_get(:OPTIONS) : {}).merge(options)
    end

    def type
      self.class.type
    end

    def required?
      !!options[:required]
    end

    def sanitize(value)
      new_value = value
      self.class.sanitizers.each do |sanitizer|
        begin
          new_value = self.send(sanitizer, new_value)
        rescue StandardError => ex
          raise ex, "Sanitizer #{sanitizer} : #{ex.message}"
        end
      end
      new_value
    end

    def errors
      @errors ||= {}
    end

    def valid?(value)
      validate(value)
      errors.empty?
    end

    def validate(value)
      errors.clear
      if value.nil?
        errors[:presence] = "Required value missing" if required? 
      else
        (Type.validators + self.class.validators).each do |validator|
          begin
            result = self.send(validator, value)
          rescue StandardError => ex
            raise ex, "Validator #{validator} : #{ex.message}"
          end
          unless result.kind_of?(NilClass) || result.kind_of?(TrueClass)
            errors[validator] = result
          end
        end
      end
    end
  end
end

Dir[File.expand_path('../types/*.rb', __FILE__)].each {|file| require file}
