require_relative '../type'
require_relative '../extensions/hash_string_or_symbol_key'
require 'uri'

module Opto
  module Types
    class Uri < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey

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
