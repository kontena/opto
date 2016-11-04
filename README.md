# Opto

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/opto`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

  - name: "remote_driver "
    type: "enum"
    required: true
    label: "Remote Driver"
    description: "Remote Git and Auth scheme"
    options:
      - github
      - bitbucket
      - gitlab
      - gogs
  - variable: "remote_config"
    type: "password"
    required: true
    label: "Remote Config"
  - variable: "remote_config2"
    type: "password"
    required: true
    label: "Remote Config"




  - option: password
    type: password
    required: true
    label: "Your password"

  - option: foo.username
    type: string
    required: true
    min_length: 1
    max_length: 30
    strip: true
    env: FOO_USER
    transform: upcase

  - option: foo.os
    type: string
    required: true
    suggested: coreos
    options:
     - value: coreos
       display: CoreOS
       description: CoreOS Stable
     - value: ubuntu
       display: Ubuntu
       description: Ubuntu Bubuntu

  - option: foo.os
    type: string
    required: true
    default: coreos
    presets:
     - value: coreos
       display: CoreOS
       description: CoreOS Stable
     - value: ubuntu
       display: Ubuntu
       description: Ubuntu Bubuntu

  - option: foo.instances
    type: integer
    required: true
    default: 1
    min: 1
    max: 30

  - option: host.url
    type: uri
    default: http://localhost:8000
    schemes:
      - http
      - https

  - option: host.name
    type: string
    min_length: 1
    max_length: 30
    regex: /^[a-z]+?\.[a-z]+?$/
    default: %(server.hostname)

# Data is the ssl certificate contents.
# Env may contain the actual contents
# Path env may contain the path to file with contents
  - option: ssl.certificate
    type: text
    default_path: ~/.ssl/cert.pem
    extension: .pem
    path_env: SSL_CERT_PATH
    env: SSL_CERT

  - option: cert.keyfile
    type: binary
    transform: base64

# Super advanced version 2:
  - option: server.type
    options_from:
      url:
        url: http://fooserver/foo
				token_env: FOO_TOKEN
				display_value: $..option:name
				value: $..option:id
				description: $..option:desc
    default: baremetal_0

  - option: username
    presets_from:
      exec:
        command: cat /etc/passwd|cut -d"," -f1

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'opto'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opto

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/opto.

