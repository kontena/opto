module Opto
  module Setters
    # Set a value to environment.
    #
    # Hint should be a name of environment variable, such as 'HOME'
    #
    # Everything will be converted to strings unless hint is a hash with :options. (also include :name in that case)
    class Env < Opto::Setter

      using Opto::Extension::HashStringOrSymbolKey

      attr_accessor :env_name, :dont_stringify

      def normalize_hint
        raise ArgumentError, "Environment variable name not set" if hint.nil?
        if hint.kind_of?(Hash)
          raise ArgumentError, "Environment variable name not set" unless hint[:name]
          @env_name = hint[:name].to_s
        else
          @env_name = hint.to_s
        end
      end

      def set(value)
        normalize_hint
        ENV[env_name] = value.to_s
      end
    end
  end
end


