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

        require 'yaml' unless Kernel.const_defined?(:YAML)

        if hint[:file]
          yaml = YAML.safe_load(::File.read(hint[:file]), [], [], true, hint[:file])
        elsif hint[:variable]
          raise TypeError, "Option not in a group" unless option.has_group?
          other_opt = option.group.option(hint[:variable])
          raise ArgumentError, "No such option: #{hint[:variable]}" if other_opt.nil?
          yaml = YAML.safe_load(other_opt.value.to_s, [], [], true, hint[:variable])
        else
          raise TypeError, "Missing file/variable definition"
        end
        if hint[:key]
          raise TypeError, "Source is not a hash" unless yaml.kind_of?(Hash)
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
