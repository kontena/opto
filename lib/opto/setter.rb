require_relative 'extensions/snake_case'

module Opto
  # Base for Setters.
  #
  # Resolvers are scripts that can retrieve or generate a value for an option.
  # Such resolvers are for example Env, which can try to find the value for
  # the option from an environment variable. An example of generators is
  # RandomString, which can generate random strings of defined length.
  class Setter

    using Opto::Extension::SnakeCase

    attr_accessor :hint
    attr_accessor :option

    class << self
      # Find a setter using a target_name definition, such as :env or :file
      # @param [Symbol, String] target
      def for(target)
        raise NameError, "Unknown setter: #{target}" unless targets[target]
        targets[target]
      end

      def inherited(where)
        targets[where.target] = where
      end

      def targets
        @targets ||= {}
      end

      def target
        name.to_s.split('::').last.snakecase.to_sym
      end
    end

    # Initialize an instance of a setter.
    # @param hint A "hint" for the setter, for example. the environment variable name
    # @param [Opto::Option] option The option parent of this resolver instance
    # @return [Opto::Resolver]
    def initialize(hint = nil, option = nil)
      @hint = hint
      @option = option
    end

    # This is a "base" class, you're supposed to inherit from this in your setter and define a #set method.
    def set(value)
      raise RuntimeError, "#{self.class}.set not defined"
    end

    # The target "tag" of this resolver, for example: 'file' or 'env'
    def target
      self.class.target
    end
  end
end

Dir[File.expand_path('../setters/*.rb', __FILE__)].each {|file| require file}

