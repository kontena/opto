module Opto
  module Resolvers
    # Read the value from a file, path defined in hint.
    class File < Opto::Resolver

      def ignore_errors?
        return false unless hint.kind_of?(Hash) && (hint['ignore_errors'] || hint[:ignore_errors])
      end

      def file_path
        hint.kind_of?(String) ? hint : (hint['path'] || hint[:path])
      end

      def resolve
        raise ArgumentError, "File path not set" unless file_path
        if ignore_errors?
          ::File.read(hint) rescue nil
        else
          ::File.read(hint)
        end
      end
    end
  end
end


