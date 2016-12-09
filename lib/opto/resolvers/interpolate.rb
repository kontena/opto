require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

if RUBY_VERSION < '2.1'
  using Opto::Extension::SnakeCase
  using Opto::Extension::HashStringOrSymbolKey
end

module Opto
  module Resolvers
    # Interpolates values from other options into a template string.
    #
    # Example:
    # from:
    #   interpolate: mysql://admin:$mysql_admin_pass@mysql:1234/$mysql_db_name
    class Interpolate < Opto::Resolver

      using Opto::Extension::HashStringOrSymbolKey unless RUBY_VERSION < '2.1'

      def resolve
        raise TypeError, "String expected" unless hint.kind_of?(String)
        hint.gsub(/(?<!\$)\$(?!\$)\{?\w+\}?/) do |v|
          var = v.tr('${}', '')
          if option.group.nil? || option.group.option(var).nil?
            raise RuntimeError, "Variable #{var} not declared"
          end
          if option.value_of(var).nil?
            raise RuntimeError, "No value for #{var}, note that the order is meaningful"
          end
          option.value_of(var)
        end
      end
    end
  end
end
