# Opto

[![Build Status](https://travis-ci.org/kontena/opto.svg?branch=master)](https://travis-ci.org/kontena/opto)

An option parser, built for generating options from a YAML file, but can be just as well used for other things.

## YAML definition examples:

```yaml
  remote_driver:
    type: "enum"
    required: true
    label: "Remote Driver"
    description: "Remote Git and Auth scheme"
    options:  # array of options, will be used as value, label and description
      - github
      - bitbucket
      - gitlab
      - gogs

  foo_username:
    type: string
    required: true
    min_length: 1
    max_length: 30
    strip: true
    upcase: true
    env: FOO_USER

  name: foo_os
    type: enum
    required: true
    can_be_other: true # otherwise value has to be one of the options
    options:
     - value: coreos
       label: CoreOS
       description: CoreOS Stable
     - value: ubuntu
       label: Ubuntu
       description: Ubuntu Bubuntu

  foo_instances:
    type: integer
    required: true
    default: 1
    min: 1
    max: 30

  host_url:
    type: uri
    default: http://localhost:8000
    schemes:
      - file # only allow file:/// uris
```

Simple so far. Now let's mix in "resolvers" which can fetch the value from a number of sources or even generate new data:

```yaml
  vault_iv:
    type: string
    from: 
      random_string:
        length: 64
        charset: ascii_printable

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
      file:
        path: /tmp/aws_secret.txt
        ignore_errors: true # if env is not set, try to read it from this file, returns nil if not readable
      env: FOOFOO  # because the previous returned nil, this one is tried
      random_string: 30 # not there either, generate a random string.
```

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
    only_if: 
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
    skip_if: 
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
 # And these work too:

  - name: bar
    type: integer
    skip_if: 
      - foo: hello # AND
      - baz: world

  - name: bar
    type: integer
    only_if: foo   # foo is not null

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

