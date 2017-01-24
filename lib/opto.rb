require "opto/version"
require 'opto/extensions/snake_case'
require 'opto/extensions/hash_string_or_symbol_key'

require "opto/option"
require "opto/group"

require 'yaml'

# An option parser/validator/resolver
#
module Opto
  using Opto::Extension::SnakeCase
  using Opto::Extension::HashStringOrSymbolKey

  # Initialize a new Opto::Option (when input is hash) or an Opto::Group (when input is an array of hashes)
  def self.new(opts)
    case opts
    when Hash
      if opts.has_key?('name') || opts.has_key?(:name)
        Option.new(opts)
      else
        Group.new(opts)
      end
    when ::Array
      if opts.all? {|o| o.kind_of?(Hash) }
        Group.new(opts)
      else
        raise TypeError, "Invalid input, an option hash or an array of option hashes required"
      end
    else
      raise TypeError, "Invalid input, an option hash or an array of option hashes required"
    end
  end

  # Read an option (or option group) from a YAML file
  # @param [String] path_to_file
  # @param [String,Symbol] a key in the hash representation of the file, such as :variables to read the options from (instead of using the root)
  # @example
  #   Opto.read('/tmp/foo.yml', :options)
  def self.read(yaml_path, key=nil)
    opts = YAML.load(File.read(yaml_path))
    new(key.nil? ? opts : opts[key])
  end

  singleton_class.send(:alias_method, :load, :read)

end

