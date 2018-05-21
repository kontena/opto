require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

module Opto
  module Resolvers
    # Interpolates values from other options into a template string.
    #
    # Example:
    # from:
    #   interpolate: mysql://admin:$mysql_admin_pass@mysql:1234/$mysql_db_name
    class Interpolate < Opto::Resolver

      using Opto::Extension::HashStringOrSymbolKey

      def resolve
        raise TypeError, "String expected" unless hint.kind_of?(String)
        hint.gsub(/(?<!\$)\$(?!\$)\{?[\w\.]+\}?/) do |v|
          var = v.tr('${}', '')

          raise RuntimeError, "Variable #{var} not declared" if option.group.nil?
          opt = option.group.option(var)
          raise RuntimeError, "Variable #{var} not declared" if opt.nil?
          value = opt.value
          raise RuntimeError, "No value for #{var}, note that the order is meaningful" if value.nil?
          value
        end
      end
    end
  end
end
