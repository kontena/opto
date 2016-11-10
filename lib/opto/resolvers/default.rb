module Opto
  module Resolvers
    class Default < Opto::Resolver
      def resolve
        hint.default
      end
    end
  end
end
