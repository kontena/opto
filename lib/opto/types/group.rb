require_relative '../type'

module Opto
  module Types
    # A subgroup
    class Group < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey

      true_when do |value|
        value.kind_of?(Opto::Group) && !value.empty?
      end

      sanitizer :init do |value|
        if options[:variables]
          Opto::Group.new(options[:variables])
        elsif value.kind_of?(::Hash) || value.kind_of?(::Array)
          Opto::Group.new(value)
        elsif value.kind_of?(Opto::Group)
          value
        elsif value.nil?
          Opto::Group.new
        else
          raise TypeError, "Invalid type #{value.class.name} for a group"
        end
      end
    end
  end
end
