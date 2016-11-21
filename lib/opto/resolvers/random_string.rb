require_relative '../extensions/hash_string_or_symbol_key'

module Opto
  module Resolvers
    # Generates a random string.
    #
    # Requires at least  :length. 
    # Also accepts :charset which can be one of: 
    # - numbers (0-9), 
    # - letters (a-z + A-Z), 
    # - downcase (a-z), 
    # - upcase (A-Z),
    # - alphanumeric (0-9 + a-z + A-Z), 
    # - hex (0-9 + a-f), 
    # - hex_upcase (0-9 + A-F), 
    # - base64 (base64 charset (length has to be divisible by four when using base64)),
    #-  ascii_printable (all printable ascii chars)
    # - or a set of characters, for example:
    #   { length: 8, charset: '01' }  Will generate something like:  01001100
    class RandomString < Opto::Resolver

      using Opto::Extension::HashStringOrSymbolKey

      def charset(name)
        case name.to_s
        when 'numbers'
          (0..9).map(&:to_s)
        when /\A\d+\-\d+\z/, /\A[a-z]\-[a-z]\z/
          from, to = name.split('-')
          (from..to).map(&:to_s)
        when 'letters'
          charset('upcase') + charset('downcase')
        when 'downcase'
          ('a'..'z').to_a
        when 'upcase'
          ('A'..'Z').to_a
        when 'alphanumeric'
          charset('letters') + charset('numbers')
        when 'hex'
          charset('numbers') + ('a'..'f').to_a
        when 'hex_upcase'
          charset('numbers') + ('A'..'F').to_a
        when 'base64'
          charset('alphanumeric') + ['+', '/']
        when 'ascii_printable'
          (33..126).map {|ord| ord.chr}
        else
          name.to_s.split('')
        end
      end

      def resolve
        if hint.kind_of?(Hash) 
          if hint[:length].nil?
            raise ArgumentError, "Invalid settings for random string. Required: length, optional: charset. Charsets : numbers, letters, alphanumeric, hex, base64, ascii_printable and X-Y range."
          end
        elsif (hint.kind_of?(String) && hint.to_i > 0) || hint.kind_of?(Fixnum)
          self.hint = { length: hint.to_i }
        else
          raise ArgumentError, "Missing settings for random string."
        end

        if hint[:charset].to_s == 'base64' && hint[:length] % 4 != 0
          raise ArgumentError, "Length must be divisible by 4 when using base64"
        end

        chars = charset(hint[:charset] || 'alphanumeric')
        (1..hint[:length].to_i).each_with_object('') do |_, str|
          str << chars.sample
        end
      end
    end
  end
end




