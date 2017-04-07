module Opto
  module Extension
    # Refines Hash so that [] and delete work with :symbol or 'string' keys
    module HashStringOrSymbolKey
      refine Hash do
        def [](key)
          return super(nil) if key.nil?

          [key, key.to_s, key.to_sym].each do |k|
            val = super(k)
            return val unless val.nil?
          end
          super(key)
        end

        def has_key?(key)
          return super(nil) if key.nil?
          [key, key.to_s, key.to_sym].each do |k|
            return true if super(k)
          end
          false
        end

        def delete(key)
          return nil if key.nil?
          [key, key.to_s, key.to_sym].each do |k|
            val = super(k)
            return val unless val.nil?
          end
          nil
        end
      end
    end
  end
end
