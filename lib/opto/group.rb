module Opto
  class Group

    attr_reader :options

    extend Forwardable

    def initialize(opts)
      @options = opts.map {|opt| Option.new(opt.merge(group: self)) }
    end

    def valid?
      options.all? {|o| o.valid? }
    end

    def errors
      Hash[*options_with_errors.flat_map {|o| [o.name, o.errors] }]
    end

    def options_with_errors
      options.reject(&:valid?)
    end

    def to_a
      options.map(&:to_h)
    end

    def build_option(args={})
      options << Option.new(args.merge(group: self))
      options.last
    end

    def option(option_name)
      options.find { |opt| opt.name == option_name.downcase }
    end

    def value_of(option_name)
      opt = option(option_name)
      opt.nil? ? nil : opt.value
    end

    def_delegators :@options, *(Array.instance_methods - [:__send__, :object_id, :to_h, :to_a, :is_a?, :kind_of?, :instance_of?])
  end
end
