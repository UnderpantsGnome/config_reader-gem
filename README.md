# ConfigReader

![Specs](https://github.com/UnderpantsGnome/config_reader-gem/actions/workflows/ruby.yml/badge.svg)
![Ruby 3.0+](https://img.shields.io/badge/Ruby-%3E%3D%203.0-success)

`ConfigReader` loads environment-specific settings from YAML, merges each
environment with `defaults`, and exposes the result through method access,
hash access, and `dig`.

## Installation

Add the gem to your application's Gemfile:

```ruby
gem "config_reader"
```

If you use encrypted config files with `sekrets_file`, add `sekrets` too:

```ruby
gem "sekrets", "~> 1.14"
```

## Config Format

`defaults` is required. `config.environment` must match one of the top-level
environment keys in the file.

```yaml
defaults:
  site_url: http://localhost:3000
  host_name: example.com
  mail_from: noreply@example.com
  features:
    search: true

production:
  site_url: http://example.com

test:
  features:
    search: false
```

## Setup

```ruby
class MyConfig < ConfigReader
  configure do |config|
    config.environment = Rails.env
    config.config_file = "config/my_config.yml"
    config.sekrets_file = "config/my_config.yml.enc" # optional
    config.ignore_missing_keys = false # default
    config.permitted_classes = [] # optional
  end
end
```

`config_file` may be an exact path. If that path does not exist, ConfigReader
also checks the current directory and `config/`.

## Usage

Top-level and nested values are available through methods, `[]`, and `dig`:

```ruby
MyConfig.mail_from
MyConfig[:mail_from]
MyConfig["mail_from"]

MyConfig.features.search
MyConfig[:features][:search]
MyConfig.dig(:features, :search)
```

Arrays work with `dig` too:

```ruby
MyConfig.dig(:servers, 0, :host)
```

If you want to read a dotted path from user input, use `dig_path`:

```ruby
#!/usr/bin/env ruby

require "bundler/setup"
require_relative "../app/lib/config"

print Config.dig_path(ARGV.fetch(0))
```

`parse_path` is also public if you need the normalized path segments:

```ruby
MyConfig.parse_path("servers.0.host")
# => [:servers, 0, :host]
```

String paths treat numeric segments as array indexes. If you need a literal key
that contains `.` or looks numeric, pass an array instead:

```ruby
MyConfig.dig_path([:numeric_keys, "0"])
MyConfig.dig_path(["smtp.example.com"])
```

You can inspect the resolved config for all environments and reload it at
runtime:

```ruby
MyConfig.envs["production"]
MyConfig.reload
```

By default, missing keys raise `KeyError`. To return `nil` instead:

```ruby
class LenientConfig < ConfigReader
  configure do |config|
    config.environment = Rails.env
    config.config_file = "config/my_config.yml"
    config.ignore_missing_keys = true
  end
end
```

## Sekrets

ConfigReader supports Sekrets integration, but only loads the `sekrets` gem
when `sekrets_file` is configured.

The sekrets file uses the same structure as the main config file. Sekrets
values are merged after the normal defaults plus environment merge, so matching
sekrets values override plain YAML values.

```ruby
class SecureConfig < ConfigReader
  configure do |config|
    config.environment = Rails.env
    config.config_file = "config/my_config.yml"
    config.sekrets_file = "config/my_config.yml.enc"
  end
end
```

See <https://github.com/ahoward/sekrets> for more information.

## Advanced YAML

ERB is evaluated before the YAML is parsed:

```yaml
defaults:
  cache_url: <%= ENV.fetch("CACHE_URL", "redis://localhost:6379/0") %>
```

YAML is loaded with `Psych.safe_load`. `Symbol` is always permitted, and you
can allow additional classes through `permitted_classes`:

```ruby
class TypedConfig < ConfigReader
  configure do |config|
    config.environment = Rails.env
    config.config_file = "config/my_config.yml"
    config.permitted_classes = [Date, Time]
  end
end
```

## Contributing

- Fork the project.
- Make your change.
- Add or update tests.
- Open a pull request.

## Copyright

Copyright (c) Michael Moen. See LICENSE for details.
