module Opto
  module Extension
    module HashStringOrSymbolKey
      refine Hash do
        def [](key)
          return nil if key.nil?
          super(key.to_s) || super(key.to_sym)
        end

        def delete(key)
          return nil if key.nil?
          super(key) || super(key.to_s) || super(key.to_sym)
        end
      end
    end
  end
end

