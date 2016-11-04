# Opto

YAML definition examples:

```yaml
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

```
