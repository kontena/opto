require "opto/version"
require "opto/option"
require "opto/group"
require 'yaml'

module Opto
  def self.new(opts)
    case opts
    when Hash
      Option.new(opts)
    when Array
      if opts.all? {|o| o.kind_of?(Hash) }
        Group.new(opts)
      else
        raise TypeError, "Invalid input, an option hash or an array of option hashes required"
      end
    else
      raise TypeError, "Invalid input, an option hash or an array of option hashes required"
    end
  end

  def self.read(yaml_path, key=nil)
    opts = YAML.load(File.read(yaml_path))
    new(key.nil? ? opts : opts[key])
  end

  singleton_class.send(:alias_method, :load, :read)

end
