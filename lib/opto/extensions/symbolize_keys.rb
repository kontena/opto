module Opto
  module Extension
    # Refines hash to have #symbolize_keys which symbolizes all keys.
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
