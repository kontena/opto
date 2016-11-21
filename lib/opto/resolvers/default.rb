module Opto
  module Resolvers
    # Resolve a value through the default value defined during option initialization
    class Default < Opto::Resolver
      def resolve
        hint.default
      end
    end
  end
end
