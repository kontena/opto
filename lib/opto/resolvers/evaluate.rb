require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

if RUBY_VERSION < '2.1'
  using Opto::Extension::SnakeCase
  using Opto::Extension::HashStringOrSymbolKey
end

module Opto
  module Resolvers
    # Geneerate a new random number. Requires :min and :max in hint to define range.
    class Evaluate < Opto::Resolver

      using Opto::Extension::HashStringOrSymbolKey unless RUBY_VERSION < '2.1'

      def resolve
        raise TypeError, "String required" unless hint.kind_of?(String)
        interpolated_hint = hint.gsub(/(?<!\$)\$(?!\$)\{?\w+\}?/) do |v|
          var = v.tr('${}', '')
          if option.group.nil? || option.group.option(var).nil?
            raise RuntimeError, "Variable #{var} not declared"
          end
          if option.value_of(var).nil?
            raise RuntimeError, "No value for #{var}, note that the order is meaningful"
          end
          option.value_of(var)
        end.gsub(/\s+/, "")

        if interpolated_hint =~ /\A[\(\)\-\+\/\*0-9]+\z/
          eval(interpolated_hint)
        else
          raise TypeError, "Syntax error: '#{interpolated_hint}' does not look like a number or a calculation"
        end
      end
    end
  end
end

