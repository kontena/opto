# Opto

[![Build Status](https://travis-ci.org/kontena/opto.svg?branch=master)](https://travis-ci.org/kontena/opto)

An option parser, built for generating options from YAML based [Kontena](https://github.com/kontena/kontena/) stack
definition files, but can be just as well used for other things, such as an API input validator.

The values for options can be resolved from files, env-variables, custom interactive prompts, random generators, etc.

The option type handlers can perform validations, such as defining a range or length requirements.

Transformations can be performed on values, such as upcasing strings or removing white space.

Options can have simple conditionals for determining if it needs to be processed or not, an option for defining a database
password can be processed only if a database has been selected.

Finally the value for the option can be placed to some destination, such as an environment variable or sent to a command.

## Installation

```ruby
# gem install opto

require 'opto'
```

## YAML definition examples:

```yaml
# Enum type
  remote_driver:
    type: "enum"
    required: true
    label: "Remote Driver"
    description: "Remote Git and Auth scheme"
    options:
      - github
      - bitbucket
      - gitlab
      - gogs
```

```yaml
# String validation and transformation
  foo_username:
    type: string
    required: true
    min_length: 1
    max_length: 30
    strip: true   # remove leading / trailing whitespace
    upcase: true  # make UPCASE
    from:
      env: FOO_USER # read value from ENV variable FOO_USER
```

```yaml
# Enum with prettier item descriptions
  name: foo_os
    type: enum
    can_be_other: true # otherwise value has to be one of the options to be valid.
    options:
     - value: coreos
       label: CoreOS
       description: CoreOS Stable
     - value: ubuntu
       label: Ubuntu
       description: Ubuntu Bubuntu
```

```yaml
# Integer with default value and allowed range
  foo_instances:
    type: integer
    default: 1
    min: 1
    max: 30
```

```yaml
# Uri validator
  host_url:
    type: uri
    schemes:
      - file # only allow file:/// uris
```

## Resolvers

Simple so far. Now let's mix in "resolvers" which can fetch the value from a number of sources or even generate new data:

```yaml
# Generate random strings
  vault_iv:
    type: string
    from: 
      random_string:
        length: 64
        charset: ascii_printable # Other charsets include hex, hex_upcase, alphanumeric, etc.
```

```yaml
# Try to get value from multiple sources
  aws_secret:
    type: string
    strip: true # removes any leading / trailing whitespace from a string
    upcase: true # turns the string to upcase
    from:
      env: 'FOOFOO'
      file: /tmp/aws_secret.txt  # if env is not set, try to read it from this file, raises if not readable

  aws_secret:
    type: string
    strip: true # removes any leading / trailing whitespace from a string
    upcase: true # turns the string to upcase
    from:
      env: FOOFOO
      file:  # if env is not set, try to read it from this file, returns nil if not readable
        path: /tmp/aws_secret.txt
        ignore_errors: true 
      random_string: 30 # not there either, generate a random string.
```

## Setters

Ok, so what to do with the values? There's setters for that.

```yaml
  aws_secret:
    type: string
    from:
      env: AWS_TOKEN
    to:
      env: AWS_SECRET_TOKEN # once a valid value is set, set it to this variable.

# There aren't any more setters right now, but one could imagine setters such as
# output to a file, interpolate into a file, run a command, etc.
```

## Conditionals

There's also rudimentary conditional support:

```yaml
  - name: foo
    type: string
    value: 'hello'
  - name: bar
    type: integer
    only_if:       # only process if 'foo' has the value 'hello'
      - foo: hello
```

```ruby
 group.option('bar').skip? 
 => false
 group.option('foo').value = 'world'
 group.option('bar').skip? 
 => true
```

```yaml
  - name: bar
    type: integer
    skip_if:   # same but reverse, do not process if 'foo' has value 'hello'
      - foo: 'hello'
```

```ruby
 group.option('foo').value = 'world'
 group.option('bar').skip? 
 => false
 group.option('foo').value = 'hello'
 group.option('bar').skip? 
 => true
```

```yaml
 # These work too:

  - name: bar
    type: integer
    skip_if: 
      - foo: hello # AND
      - baz: world

  - name: bar
    type: integer
    only_if: foo   # process if foo is not null, false or 'false'

  - name: bar
    type: integer
    only_if:
      - foo   # foo is not null
      - baz   # AND baz is not null
```

Pretty nifty, right?

## Examples

```ruby
# Read definitions from 'options' key inside a YAML:
Opto.load('/tmp/stack.yml', :options)

# Read definitions from root of YAML
Opto.load('/tmp/stack.yml')

# Create an option group:
Opto.new( [ {name: 'foo', type: :string} ] )
# or
group = Opto::Group.new
group.build_option(name: 'foo', type: :string, value: "hello")
group.build_option(name: 'bar', type: :string, required: true)
group.first
=> #<Opto::Option:xxx>
group.size
=> 2
group.each { .. }
group.errors
=> { 'bar' => { :presence => "Required value missing" } }
group.options_with_errors.each { ... }
group.valid?
=> false
```

## Creating a custom resolver

Want to prompt for values? Try something like this:

```ruby
# gem install tty-prompt
require 'tty-prompt'
class Prompter < Opto::Resolver
  def resolve
    # option = accessor to the option currently being resolved
    # option.handler = accessor to the type handler
    # hint = resolver options, for example the env variable name for env resolver, not used here.
    return nil if option.skip?
    if option.type == :enum
      TTY::Prompt.new.select("Select #{option.label}") do |menu|
        option.handler.options[:options].each do |opt| # quite ugly way to access the option's value list definition
          menu.choice opt[:label], opt[:value]
        end
      end
    else
      TTY::Prompt.new.ask("Enter value for #{option.label}")
    end
  end
end

# And the option:
- name: foo
  type: enum
  options:
    - foo: Foo
    - bar: Bar
  from: prompter
```

## Subclassing a predefined type handler, setter, etc

```ruby
class VersionNumber < Opto::Types::String
  Opto::Type.inherited(self) # need to call Opto::Type.inherited for registering the handler for now.

  OPTIONS = Opto::Types::String::OPTIONS.merge(
    min_version: nil,
    max_version: nil
  )

  validate :min_version do |value|
    if options[:min_version] && value < options[:min_version]
      "Minimum version required: #{options[:min_version]}"
    end
  end

  validate :max_version do |value|
    if options[:max_version] && value > options[:max_version]
      "Maximum version: #{options[:max_version]}, yours is #{value}"
    end
  end

  sanitize :remove_build_info do |value|
    value.split('+').first
  end
end

# And to use:
> opt = Opto::Option.new(type: :version_number, name: 'foo', minimum_version: '1.0.0')
> opt.value = '0.1.0'
> opt.valid?
=> false
> opt.errors
=> { :validate_min_version => "Minimum version required: 1.0.0" }
```

## Default types

Global validations:

```yaml
  in:  # only allow one of the following values
    - a
    - b
    - c
```

### boolean

```ruby
{
   truthy: ['true', 'yes', '1', 'on', 'enabled', 'enable'], # These strings will be turned into true
   nil_is: false, # If the value is null, set to false
   blank_is: false, # If the value is a blank string, set to false
   false: 'false', # When outputting, emit this value when value is false
   true: 'true',   # When outputting, emit this value when value is true
   as: 'string'    # Output a string, can be 'boolean' or 'integer'
}
```

### enum

```ruby
{
  options: [],  # List of the possible option values
  can_be_other: false  # Or allow values outside the option list
}
```

### integer
```ruby
{
  min: 0, # minimum value, can be negative
  max: nil, # maximum value
  nil_is_zero: false # null value will be turned into zero
}
```

### string
```ruby
{
  min_length: nil, # minimum length
  max_length: nil, # maximum length
  hexdigest: nil,  # hexdigest output. options: md5, sha1, sha256, sha384 or sha512.
  empty_is_nil: true, # if string contains whitespace only, make value null
  encode_64: false, # encode content to base64
  decode_64: false, # decode content from base64
  upcase: false, # convert to UPPERCASE
  downcase: false, # convert to lowercase
  strip: false, # remove leading/trailing whitespace,
  chomp: false, # remove trailing linefeed
  capitalize: false # convert to Capital case.
}
```

### uri
```ruby
{
  schemes: [ 'http', 'https' ] # only http and https urls are considered valid
}
```

## Default resolvers
Hint is the value that gets passed to the resolver when doing for example: `env: FOO` (FOO is the hint)

### env
Hint is the environment variable name to read from. Defaults to the option's name.

### file
Hint can be a string containing a path to the file, or a hash that defines `path: 'file_path', ignore_errors: true`

### random_number
Hint must be a hash containing `min: minimum_number, max: maximum_number`

### random_string
Hint can be a string/number that defines minimum length. Default charset is 'alphanumeric'
Hint can also be a hash that defines `length: length_of_generated_string, charset: 'charset_name'`

Defined charsets:
 * numbers (0-9)
 * letters (a-z + A-Z)
 * downcase (a-z)
 * upcase (A-Z)
 * alphanumeric (0-9 + a-z + A-Z)
 * hex (0-9 + a-f)
 * hex_upcase (0-9 + A-F)
 * base64 (base64 charset (length has to be divisible by four when using base64))
 * ascii_printable (all printable ascii chars)
 * or a set of characters, for example: { length: 8, charset: '01' }  Will generate something like:  01001100

### random_uuid
Ignores hint completely.

Output is a 'random' UUID generated by `SecureRandom.uuid`, such as `78b6decf-e312-45a1-ac8c-d562270036ba`

### evaluate
Hint is a calculation. Uses values of other options to perform simple calculations.

Example:

```yaml
apples:
  type: integer
  value: 2

bananas:
  type: integer
  value: 1

fruits:
  type: integer
  from:
    evaluate: ${apples} + ${bananas}

# group.value_of('fruits') => 3

### interpolate
Hint is a template. Uses values from other options to build a string.

Example:

```yaml
place:
  type: string
  value: world

greeting:
  type: string
  from:
    interpolate: Hello, ${place}!

# group.value_of('greeting') => "Hello, world!"
```

## Default setters

### env
Works exactly the same as env resolver, except in reverse.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kontena/opto. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

