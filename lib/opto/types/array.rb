require_relative '../type'

module Opto
  module Types
    # An array
    #
    # Options:
    #   - split: an incoming string will be split using this pattern
    #   - join: when outputting, join the array using this pattern into a string
    #   - empty_is_nil: an empty array will be replaced with nil
    #   - sort: when true, sorts the array before output
    #   - uniq: when true, removes duplicates
    #   - compact: when true, removes nils and blanks
    #   - count: when true, the output is the count of items in the array
    class Array < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey


      OPTIONS = {
        split: ',',
        join: false,
        empty_is_nil: false,
        sort: false,
        uniq: false,
        count: false,
        compact: false
      }

      sanitizer :split do |value|
        if value.kind_of?(::Array)
          value
        elsif value.kind_of?(::String)
          value.split(options[:split])
        elsif value.nil?
          []
        else
          [value]
        end
      end

      sanitizer :sort do |value|
        (value && options[:sort]) ? value.sort : value
      end

      sanitizer :uniq do |value|
        (value && options[:uniq]) ? value.uniq : value
      end

      sanitizer :compact do |value|
        (value && options[:compact]) ? value.compact : value
      end

      sanitizer :empty_is_nil do |value|
        (options[:empty_is_nil] && value.empty?) ? nil : value
      end

      sanitizer :output do |value|
        if value
          if options[:join]
            value.join(options[:join])
          elsif options[:count]
            value.size
          else
            value
          end
        else
          nil
        end
      end
    end
  end
end
