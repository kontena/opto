if RUBY_VERSION < '2.1'
  require 'opto/extensions/snake_case'
  require 'opto/extensions/hash_string_or_symbol_key'
  using Opto::Extension::SnakeCase
  using Opto::Extension::HashStringOrSymbolKey
end

module Opto
  module Resolvers
    # Geneerate a new random number. Requires :min and :max in hint to define range.
    class RandomNumber < Opto::Resolver

      using Opto::Extension::HashStringOrSymbolKey unless RUBY_VERSION < '2.1'

      def resolve
        raise ArgumentError, "Range not set" if hint.nil?

        unless hint.kind_of?(Hash)
          raise TypeError, "Range invalid, define min: and max: using hash syntax"
        end

        unless hint[:min]
          raise ArgumentError, "Range definition missing :min"
        end

        unless hint[:max]
          raise ArgumentError, "Range definition missing :max"
        end

        rand(hint[:min]..hint[:max])
      end
    end
  end
end
