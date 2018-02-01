# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'config_reader/version'

Gem::Specification.new do |s|
  s.name        = 'config_reader'
  s.version     = ConfigReader::VERSION
  s.authors     = ['Michael Moen']
  s.email       = ['michael@underpantsgnome.com']
  s.homepage    = 'https://github.com/UnderpantsGnome/config_reader-gem'
  s.summary     = %q{Provides a way to manage environment specific configuration settings.}
  s.description = %q{Provides a way to manage environment specific configuration settings.}

  s.rubyforge_project = 'config_reader'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_dependency 'deep_merge'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '1.3.2'
  s.add_development_dependency 'sekrets', '~> 1.7.0'
  s.add_development_dependency 'pry'

  s.post_install_message = "If you are are upgrading from a pre 2.x version, please see the configuration changes in the README https://github.com/UnderpantsGnome/config_reader-gem/blob/master/README.rdoc"
end
