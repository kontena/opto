module Opto
  module Resolvers
    # Read the value from a file, path defined in hint.
    class File < Opto::Resolver

      def ignore_errors?
        return false unless hint.kind_of?(Hash) && (hint['ignore_errors'] || hint[:ignore_errors])
      end

      def file_path
        if hint.kind_of?(String)
          hint
        elsif hint.kind_of?(Hash) && (hint['path'] || hint[:path])
          hint['path'] || hint[:path]
        else
          raise ArgumentError, "File path not set"
        end
      end

      def resolve
        if ignore_errors?
          file_path
          ::File.read(file_path) rescue nil
        else
          ::File.read(file_path)
        end
      end
    end
  end
end


