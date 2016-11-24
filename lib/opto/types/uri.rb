require_relative '../type'
require 'uri'

if RUBY_VERSION < '2.1'
  require 'opto/extensions/snake_case'
  require 'opto/extensions/hash_string_or_symbol_key'
  using Opto::Extension::SnakeCase
  using Opto::Extension::HashStringOrSymbolKey
end

module Opto
  module Types
    # An uri/url.
    #
    # Options:
    #   schemes: an array of allowed schemes, such as ['http', 'https', 'file']
    class Uri < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey unless RUBY_VERSION < '2.1'

      OPTIONS = {
        schemes: [ 'http', 'https' ]
      }

      validator :scheme do |value|
        return nil if options[:schemes].nil? || options[:schemes].empty?
        scheme = uri(value).scheme
        return nil if options[:schemes].include?(scheme)
        "Uri scheme '#{scheme}' not allowed, allowed schemes: #{options[:schemes].join(', ')}"
      end

      def uri(value)
        URI.parse(value)
      end
    end
  end
end
