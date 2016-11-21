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
        val = ENV[hint.to_s]
        return nil if val.nil?
        case val
        when /\A\d+\z/ then val.to_i
        when /\Atrue\z/ then true
        when /\Afalse\z/ then false
        when /\A(?:null|nil)\z/ then nil
        else val
        end
      end
    end
  end
end

