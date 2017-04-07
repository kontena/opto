module Opto
  module Resolvers
    # Find a value using Environment.
    #
    # Hint should be a name of environment variable, such as 'HOME'
    #
    # Numbers will be converted to fixnums, "true" and "false" will be converted to booleans.
    class Env < Opto::Resolver

      def resolve
        raise ArgumentError, "Environment variable name not set" if hint.nil?
        Array(hint).each do |hint|
          val = ENV[hint.to_s]
          val = case val
          when NilClass then nil
          when /\A\d+\z/ then val.to_i
          when /\Atrue\z/ then true
          when /\Afalse\z/ then false
          when /\A(?:null|nil)\z/ then nil
          else val
          end
          return val unless val.nil?
        end
        nil
      end
    end
  end
end

