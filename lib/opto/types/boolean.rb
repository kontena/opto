require_relative '../type'
require_relative '../extensions/hash_string_or_symbol_key'

module Opto
  module Types
    class Boolean < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey

      OPTIONS = {
        min: 0,
        max: nil,
        truthy: ['true', 'yes', '1', 'on', 'enabled', 'enable'],
        nil_is: false,
        blank_is: false,
        false: 'false',
        true: 'true',
        as: 'string'
      }

      sanitizer :to_bool do |value|
        if value.nil?
          options[:nil_is]
        elsif value.to_s.strip == ''
          options[:blank_is]
        else
          options[:truthy].include?(value.to_s.strip.downcase)
        end
      end

      sanitizer :output do |value|
        case options[:as].to_s.strip.downcase
        when 'integer'
          value ? (options[:true].kind_of?(Fixnum) ? options[:true] : 1) : (options[:false].kind_of?(Fixnum) ? options[:false] : 0)
        when 'boolean'
          value
        else
          value ? options[:true] : options[:false]
        end
      end
    end
  end
end
