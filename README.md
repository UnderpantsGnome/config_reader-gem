# ConfigReader

![Maintainability](<img
src="https://codeclimate.com/github/UnderpantsGnome/config_reader-gem.png"/>](https://codeclimate.com/github/UnderpantsGnome/config_reader-gem)
![Maintainability](<img src="https://github.com/UnderpantsGnome/config_reader-gem/actions/workflows/ruby.yml/badge.svg" />)
![Ruby 3.0+](<imgsrc="<https://img.shields.io/badge/Ruby-3.0%2B-green>/>)

Provides a way to manage environment specific configuration settings. It will
use the defaults for any environment and override any values you specify for
an environment.

Example config file:

    defaults:
      site_url: http://localhost:3000
      host_name: example.com
      mail_from: noreply@example.com
      site_name: example
      admin_email: admin@example.com

    production:
      site_url: http://example.com

## Ruby 3.1 and 3.2

If you want to use Sekrets with these versions of Ruby you need to use this version until upstream gets updated.

```ruby
gem "sekrets",
  github: "UnderpantsGnome/sekrets",
  branch: "ruby-3-2-support"
```

## Sekrets

Includes Sekrets integration. See <https://github.com/ahoward/sekrets> for more
information.

The format of the sekrets file is the same as the regular file.

## Setup

    class MyConfig < ConfigReader
      configure do |config|
        config.environment = Rails.env # (set this however you access the env in your app)
        config.config_file = 'config/my_config.yml'
        config.sekrets_file = 'config/my_config.yml.enc' # (default nil)
        config.ignore_missing_keys = true # (default false, raises KeyError)
      end
    end

## Usage

    MyConfig.mail_from    #=> noreply@example.com
    MyConfig[:mail_from]  #=> noreply@example.com
    MyConfig['mail_from'] #=> noreply@example.com

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future
    version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to
    have your own version, that is fine but bump version in a commit by itself
    I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) Michael Moen. See LICENSE for details.
