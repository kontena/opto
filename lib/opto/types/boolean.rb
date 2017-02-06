require_relative '../type'
require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

module Opto
  module Types
    # A boolean value.
    #
    # Options:
    #   :truthy an array of strings / values that are converted to True.
    #   :nil_is by default false
    #   :blank_is by default false too
    #   :as by default outputs a string. integer outputs a number, true_or_nil outputs true or nil. set to nil to just output whatever is in :true and :false
    #   :true says "true" by default when outputting a string
    #   :false says "false" by default when outputting a string
    class Boolean < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey

      OPTIONS ||= {
        truthy: ['true', 'yes', '1', 'on', 'enabled', 'enable'],
        nil_is: false,
        blank_is: false,
        false: 'false',
        true: 'true',
        as: 'boolean'
      }

      true_when do |value|
        sanitize_to_bool(value)
      end

      sanitizer :to_bool do |value|
        if value.nil?
          options[:nil_is]
        elsif value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
          value
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
