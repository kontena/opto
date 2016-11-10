# Opto

An option parser, built for generating options from a YAML file, but can be just as well used for other things.

## YAML definition examples:

```yaml
  - name: "remote_driver "
    type: "enum"
    required: true
    label: "Remote Driver"
    description: "Remote Git and Auth scheme"
    options:  # array of options, will be used as value, label and description
      - github
      - bitbucket
      - gitlab
      - gogs

  - name: foo.username
    type: string
    required: true
    min_length: 1
    max_length: 30
    strip: true
    upcase: true
    env: FOO_USER

  - name: foo.os
    type: string
    required: true
    can_be_other: true # otherwise value has to be one of the options
    options:
     - value: coreos
       label: CoreOS
       description: CoreOS Stable
     - value: ubuntu
       label: Ubuntu
       description: Ubuntu Bubuntu

  - name: foo.instances
    type: integer
    required: true
    default: 1
    min: 1
    max: 30

  - name: host.url
    type: uri
    default: http://localhost:8000
    schemes:
      - file # only allow file:/// uris
```

Simple so far. Now let's mix in "resolvers" which can fetch the value from a number of sources or even generate new data:

```yaml
  - name: vault_iv
    type: string
    from: 
      random_string:
        length: 64
        charset: ascii_printable

  - name: aws_secret
    type: string
    strip: true # removes any leading / trailing whitespace from a string
    upcase: true # turns the string to upcase
    from:
      env: 'FOOFOO'
      file: /tmp/aws_secret.txt  # if env is not set, try to read it from this file, raises if not readable

  - name: aws_secret
    type: string
    strip: true # removes any leading / trailing whitespace from a string
    upcase: true # turns the string to upcase
    from:
      file: 
        path: /tmp/aws_secret.txt
        ignore_errors: true # if env is not set, try to read it from this file, returns nil if not readable
      env: 'FOOFOO'  # because the previous returned nil, this one is tried
      random_string: 30 # not there either, generate a random string.
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

## Todo
- Document the available types, resolvers and validations.
- Add YARDocs
