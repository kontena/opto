module Opto
  class Type
    GLOBAL_OPTIONS = {
      required: true
    }

    attr_accessor :option
    attr_accessor :options


    class << self
      def inherited(klass)
        @handlers ||= {}
        @handlers[klass.to_s.split('::').last] = klass
      end

      def type(type_name=nil)
        return @type unless type_name
        @type = type_name
      end

      def handler_for(type_name)
        if @handlers[type_name]
          @handlers[type_name]
        else
          raise TypeError, "No handler for type #{type_name}"
        end
      end

      def validators
        @validators ||= []
      end

      def validates(name, &block)
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

    validates :presence do 
      (required? && value.nil?) ? "Missing value for #{option.name}" : true
    end

    def initialize(option, options = {})
      @option = option
      @options = Type::GLOBAL_OPTIONS.merge(self.class::OPTIONS).merge(options)
    end

    def value
      option.value
    end

    def value=(value)
      option.value = value
      sanitize
      option.value
    end

    def required?
      options[:required]
    end

    def sanitize
      self.class.sanitizers.each do |sanitizer|
        begin
          @value = self.send(sanitizer)
        rescue StandardError => ex
          raise ex, "Sanitizer #{sanitizer} : #{ex.message}"
        end
      end
      @value
    end

    def validate
      errors = {}
      self.class.validators.each do |validator|
        result = self.send(validator)
        unless result.kind_of?(NilClass) || result.kind_of?(TrueClass)
          errors[validator] = result
        end
      end
      errors
    end
  end
end

Dir[File.expand_path('../types/*.rb', __FILE__)].each {|file| require file}
