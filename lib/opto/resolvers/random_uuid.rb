require 'securerandom'

module Opto
  module Resolvers
    class RandomUuid < Opto::Resolver
      def resolve
        SecureRandom.uuid
      end
    end
  end
end



