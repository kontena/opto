module Opto
  module Resolvers
    # Find a value of another variable.
    #
    # Hint should be a name of another variable
    class Variable < Opto::Resolver

      def resolve
        raise ArgumentError, "Variable name not set" if hint.nil?
        if option.group.nil? || option.group.option(hint).nil?
          raise RuntimeError, "Variable #{hint} not declared"
        end
        option.value_of(hint)
      end
    end
  end
end


