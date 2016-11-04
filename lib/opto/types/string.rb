require_relative '../type'

module Opto
  module Types
    class String < Opto::Type
      OPTIONS = {
        min_length: nil,
        max_length: nil,
        empty_is_nil: true,
        strip: true
      }

      sanitizer :strip do
        (options[:strip] && value.respond_to?(:strip)) ? value.strip : value
      end

      sanitizer :empty_is_nil do
        (options[:empty_is_nil] && value.to_s.strip.empty?) ? nil : value.to_s
      end

      validates :min_length do
        if options[:min_length] && value.length < options[:min_length]
          "Too short. Minimum length is #{options[:min_length]}, value length is #{value.length}."
        end
      end

      validates :max_length do
        if options[:max_length] && value.length > options[:max_length]
          "Too long. Maximum length is #{options[:max_length]}, value length is #{value.length}."
        end
      end
    end
  end
end
