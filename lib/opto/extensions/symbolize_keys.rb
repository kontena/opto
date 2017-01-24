module Opto
  module Extension
    # Refines String to have .snakecase method that turns
    # StringLikeThis into a string_like_this
    module SymbolizeKeys
      refine Hash do
        def symbolize_keys
          each_with_object(dup.clear) do |(key, value), hash|
            hash[(key.to_sym rescue key)] = value
          end
        end
      end
    end
  end
end
