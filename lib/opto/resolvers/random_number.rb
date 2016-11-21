require_relative '../extensions/hash_string_or_symbol_key'

module Opto
  module Resolvers
    # Geneerate a new random number. Requires :min and :max in hint to define range.
    class RandomNumber < Opto::Resolver

      using Opto::Extension::HashStringOrSymbolKey

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
