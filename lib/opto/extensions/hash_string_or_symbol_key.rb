module Opto
  module Extension
    # Refines Hash so that [] and delete work with :symbol or 'string' keys
    module HashStringOrSymbolKey
      refine Hash do
        def [](key)
          return nil if key.nil?
          super(key.to_s) || super(key.to_sym)
        end

        def has_key?(key)
          if key.nil?
            super(nil)
          else
            super(key.to_s) || super(key.to_sym)
          end
        end

        def delete(key)
          return nil if key.nil?
          super(key) || super(key.to_s) || super(key.to_sym)
        end
      end
    end
  end
end
