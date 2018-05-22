require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

module Opto
  module Resolvers
    # Allows setting the value conditionally based on other variables
    #
    # Example:
    # from:
    #   condition:
    #     - if:
    #         db_instances: 1
    #       then: single
    #     - elsif:
    #         db_instances:
    #           gt: 1
    #       then: multi
    #     - else: none
    #
    # Which is the same as:
    # if $db_instances == 1
    #   return "single"
    # elsif $db_instances > 1
    #   return "multi"
    # else
    #   return "none"
    # end
    #
    # If you don't define an else, a null will be returned when no conditions match.
    class Condition < Opto::Resolver

      using Opto::Extension::HashStringOrSymbolKey

      class HashCond
        attr_reader :condition
        attr_reader :result
        attr_reader :group

        def initialize(group, options={})
          @group = group
          if options.has_key?(:else)
            @result = options[:else]
            @else = true
          elsif options.has_key?(:if) || options.has_key?(:elsif)
            @condition = options[:if] || options[:elsif]
            if options.has_key?(:then)
              @result = options[:then]
            else
              raise ArgumentError, "Invalid condition definition: #{options.inspect} (no 'then')"
            end
            @else = false
          else
            raise ArgumentError, "Invalid condition definition: #{options.inspect} (no 'if', 'elsif' or 'else')"
          end
        end

        def else?
          @else
        end

        def true?
          return true if else?
          return true if group.all_true?(condition)
          false
        end
      end

      def resolve
        raise TypeError, "An Array of Hashes expected" unless hint.kind_of?(Array)
        raise TypeError, "An Array of Hashes expected" unless hint.all? {|h| h.kind_of?(Hash) }
        raise TypeError, "Can't use condition resolver when option isn't a member of an option group" if option.group.nil?

        conditions = hint.map {|h| HashCond.new(option.group, h) }

        unless conditions.last.else?
          conditions << HashCond.new(:else => nil)
        end

        matching_condition = conditions.find {|c| c.true? }
        matching_condition.result
      end
    end
  end
end

