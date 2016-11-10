require_relative '../type'
require_relative '../extensions/hash_string_or_symbol_key'

module Opto
  module Types
    class Integer < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey

      OPTIONS = {
        min: 0,
        max: nil
      }

      sanitizer :to_i do |value|
        value.to_i
      end

      validator :min do |value|
        if options[:min] && value < options[:min]
          "Too small. Minimum value is #{options[:min_length]}, Value is #{value}."
        end
      end

      validator :max do |value|
        if options[:max] && value > options[:max]
          "Too large. Maximum value is #{options[:max]}, Value is #{value}."
        end
      end
    end
  end
end

