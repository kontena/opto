module Opto
  class Resolver

    attr_accessor :option
    attr_reader   :hint

    def self.inherited(base)
      @resolvers ||= []
      @resolvers << base
    end

    def self.resolvers(*filters)
      @resolvers || {}
    end

    def self.resolver(origin)
      resolver = resolvers.find { |resolver| resolver.origin == origin }
      raise TypeError, "Unknown resolver: #{origin}" unless resolver
      resolver
    end

    def self.origin(value_source=nil)
      return @origin unless value_source
      @origin = value_source
    end

    def initialize(option, hint = nil)
      @option = option
      @hint = hint
    end

    def resolve
      raise StandardError, "#{self.class}.resolve not defined"
    end
  end
end

Dir[File.expand_path('../resolvers/*.rb', __FILE__)].each {|file| require file}
