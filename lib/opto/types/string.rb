require_relative '../type'
require 'base64'
require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

module Opto
  module Types
    # A string
    #
    # Options:
    #   - min_length: minimum lenght
    #   - max_length: maximum length
    #   - empty_is_nil: an empty string will be replaced with nil
    #   - encode_64: set to true if you want the final value to be base64 encoded representation
    #   - decode_64: set to true if your string is in base64 and you want to convert to plain text
    #   - upcase: set to true to upcase the string
    #   - downcase: set to true to downcase the string
    #   - strip: set to true to remove leading and trailing whitespace
    #   - chomp: set to true to remove trailing linefeed
    #   - capitalize: set to true to upcase the first letter
    #   - hexdigest: valid options: md5, sha1, sha256, sha384, sha512 and nil/false. generate an md5/sha1/etc hexdigest from the value.
    class String < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey

      TRANSFORMATIONS = [ :upcase, :downcase, :strip, :chomp, :capitalize ]

      OPTIONS ||= {
        min_length: nil,
        max_length: nil,
        empty_is_nil: true,
        hexdigest: false,
        encode_64: false,
        decode_64: false
      }.merge(Hash[*TRANSFORMATIONS.flat_map {|tr| [tr, false]}])

      true_when do |value|
        !value.nil? && !value.strip.empty? && value != 'false'
      end

      sanitizer :encode_64 do |value|
        (options[:encode_64] && value) ? Base64.encode64(value) : value
      end

      sanitizer :decode_64 do |value|
        (options[:decode_64] && value) ? Base64.decode64(value) : value
      end

      sanitizer :hexdigest do |value|
        case options[:hexdigest]
        when 'md5'
          require 'digest/md5'
          Digest::MD5.hexdigest(value)
        when 'sha1'
          require 'digest/sha1'
          Digest::SHA1.hexdigest(value)
        when 'sha256'
          require 'digest/sha2'
          Digest::SHA256.hexdigest(value)
        when 'sha384'
          require 'digest/sha2'
          Digest::SHA384.hexdigest(value)
        when 'sha512'
          require 'digest/sha2'
          Digest::SHA512.hexdigest(value)
        when NilClass, FalseClass
          value
        else
          raise TypeError, "Invalid hexdigest, valid options: md5, sha1, sha256, sha384, sha512 and nil/false"
        end
      end

      TRANSFORMATIONS.each do |transform|
        sanitizer transform do |value|
          (options[transform] && value.respond_to?(transform)) ? value.send(transform) : value
        end
      end

      sanitizer :empty_is_nil do |value|
        (options[:empty_is_nil] && value.to_s.strip.empty?) ? nil : value.to_s
      end

      validator :min_length do |value|
        if options[:min_length] && value.length < options[:min_length]
          "Too short. Minimum length is #{options[:min_length]}, length is #{value.length}."
        end
      end

      validator :max_length do |value|
        if options[:max_length] && value.length > options[:max_length]
          "Too long. Maximum length is #{options[:max_length]}, length is #{value.length}."
        end
      end
    end
  end
end
