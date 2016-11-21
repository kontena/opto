require 'securerandom'

module Opto
  module Resolvers
    # Generates a UUID, such as "b379de07-3324-44b1-a5f3-8617ed1b41ea"
    class RandomUuid < Opto::Resolver
      def resolve
        SecureRandom.uuid
      end
    end
  end
end



