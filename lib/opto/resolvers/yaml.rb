require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

module Opto
  module Resolvers
    # Loads values from YAML files
    #
    # Example:
    # from:
    #   yaml:
    #     file: foofoo.yml
    #     key: foo
    class Yaml < Opto::Resolver

      using Opto::Extension::HashStringOrSymbolKey

      def resolve
        raise TypeError, "Hash expected" unless hint.kind_of?(Hash)
        raise TypeError, "Missing file definition" unless hint[:file]

        require 'yaml' unless Kernel.const_defined?(:YAML)
        yaml = YAML.safe_load(::File.read(hint[:file]), [], [], true, hint[:file])
        if hint[:key]
          raise TypeError, "Data file #{hint[:file]} is not a hash" unless yaml.kind_of?(Hash)
          if yaml.key?(hint[:key])
            yaml[hint[:key]]
          elsif hint[:key].include?('.')
            yaml.dig(*hint[:key].split('.'))
          end
        else
          yaml
        end
      end
    end
  end
end
