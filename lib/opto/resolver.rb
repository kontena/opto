require_relative 'extensions/snake_case'

module Opto
  # Base for resolvers.
  #
  # Resolvers are scripts that can retrieve or generate a value for an option.
  # Such resolvers are for example Env, which can try to find the value for
  # the option from an environment variable. An example of generators is
  # RandomString, which can generate random strings of defined length.
  class Resolver

    using Opto::Extension::SnakeCase

    attr_accessor :hint
    attr_accessor :option

    class << self
      # Find a resolver using an origin_name definition, such as :env or :file
      # @param [Symbol, String] origin
      def for(origin)
        raise NameError, "Unknown resolver: #{origin}" unless resolvers[origin]
        resolvers[origin]
      end

      def inherited(where)
        resolvers[where.origin] = where
      end

      def resolvers
        @resolvers ||= {}
      end

      def origin
        name.to_s.split('::').last.snakecase.to_sym
      end
    end

    # Initialize an instance of a resolver.
    # @param hint A "hint" for the resolver, for example. the environment variable name or a set of rules for generators.
    # @param [Opto::Option] option The option parent of this resolver instance
    # @return [Opto::Resolver]
    def initialize(hint = nil, option = nil)
      @hint = hint
      @option = option
    end

    # This is a "base" class, you're supposed to inherit from this in your resolver and define a #resolve method.
    def resolve
      raise RuntimeError, "#{self.class}.resolve not defined"
    end

    # The origin "tag" of this resolver, for example: 'random_string' or 'env'
    def origin
      self.class.origin
    end
  end
end

Dir[File.expand_path('../resolvers/*.rb', __FILE__)].each {|file| require file}
