module Opto
  module Resolvers
    class DefaultValue < Opto::Resolver

      origin :default

      def resolve
        option.default
      end
    end
  end
end
