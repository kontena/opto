require_relative '../type'
require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'
require 'opto/types/boolean'

module Opto
  module Types
    # A list of possible values
    #
    # :options  - a list of possible values for this enum
    # :can_be_other - set to true if the value can be outside of the value list in options
    # :in - when "can be other" is defined, this can be used to define an extra set of possible values
    #
    # @example Shorthand option list
    #   Opto::Option.new(
    #     name: 'foo',
    #     type: 'enum',
    #     options:
    #       - foo
    #       - bar
    #       - cat
    #     can_be_other: true
    #   )
    #
    # @example Detailed option list
    #   Opto::Option.new(
    #     name: 'foo',
    #     type: 'enum',
    #     options:
    #       - value: cat
    #         label: Cat
    #         description: A four legged ball of fur
    #       - value: dog
    #         label: Dog
    #         description: A friendly furry creature with a tail, says 'woof'
    #   )
    class Enum < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey

      OPTIONS = {
        options: [],
        can_be_other: false,
        in: []
      }

      true_when do |value|
        Opto::Types::Boolean.new(options).sanitize_to_bool(value)
      end

      def initialize(options={})
        opts = normalize_opts(options.delete(:options))
        super(options)
        @options[:options] = opts
      end

      validator :options do |value|
        if options[:options].nil? || options[:options].empty?
          raise RuntimeError, "No options defined for enum"
        elsif options[:options].map {|o| o[:value]}.uniq.size != options[:options].size
          raise RuntimeError, "Duplicate values in enum option list"
        end
      end

      validator :in do |value|
        return nil if options[:can_be_other]
        if options[:in] && !options[:in].empty?
          "Value is not one of #{options[:in].join(', ')}" unless options[:in].include?(value)
        else
          "Value is not one of the options" unless options[:options].map { |o| o[:value] }.include?(value)
        end
      end

      def normalize_opts(options)
        case options
        when Hash
          options.each_with_object([]) do |(key, value), array|
            array << { value: key, label: key, description: value }
          end
        when ::Array
          case options.first
          when Hash
            options.each do |opt|
              if opt[:value].nil? || opt[:description].nil?
                raise TypeError, "Option definition requires value and description and can have label when using hash syntax"
              end
            end
            options
          when ::String, Fixnum
            options.map do |opt|
              { value: opt, description: opt, label: opt }
            end
          when NilClass
            []
          else
            raise TypeError, "Invalid format for enum option list definition"
          end
        when NilClass
          []
        else
          raise TypeError, "Invalid format for enum option list definition"
        end
      end
    end
  end
end


