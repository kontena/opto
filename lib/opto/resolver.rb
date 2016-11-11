require_relative 'extensions/snake_case'

module Opto
  class Resolver

    using Opto::Extension::SnakeCase

    attr_accessor :hint

    class << self
      def inherited(where)
        resolvers[where.origin] = where
      end

      def resolvers
        @resolvers ||= {}
      end

      def for(origin)
        raise NameError, "Unknown resolver: #{origin}" unless resolvers[origin]
        resolvers[origin]
      end

      def origin
        name.to_s.split('::').last.snakecase.to_sym
      end
    end

    def initialize(hint = nil, option = nil)
      @hint = hint
      @option = option
    end

    def resolve
      raise RuntimeError, "#{self.class}.resolve not defined"
    end

    def origin
      self.class.origin
    end
  end
end

Dir[File.expand_path('../resolvers/*.rb', __FILE__)].each {|file| require file}
