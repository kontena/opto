module Opto
  module Resolvers
    # Read the value from a file, path defined in hint.
    class File < Opto::Resolver

      def resolve
        raise ArgumentError, "File path not set" unless hint.kind_of?(String)
        ::File.read(hint)
      end
    end
  end
end


