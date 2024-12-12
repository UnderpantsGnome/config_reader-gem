$:.push File.expand_path("../lib", __FILE__)
require "config_reader/version"

Gem::Specification.new do |spec|
  spec.name = "config_reader"
  spec.version = ConfigReader::VERSION
  spec.authors = ["Michael Moen"]
  spec.email = ["michael@underpantsgnome.com"]
  spec.homepage = "https://github.com/UnderpantsGnome/config_reader-gem"

  spec.summary =
    "Provides a way to manage environment specific configuration settings."

  spec.description =
    "Provides a way to manage environment specific configuration settings."

  spec.files = Dir.glob("{lib,spec}/**/*") + %w[CHANGELOG.md README.md]

  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "abbrev", ">= 0"
  spec.add_dependency "psych", "~> 5.2", ">= 5.2.1"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "sekrets", "~> 1.14"
  spec.add_development_dependency "pry"

  spec.post_install_message = <<~EOS
    If you are are upgrading from a pre 2.x version,
    please see the configuration changes in the
    README https://github.com/UnderpantsGnome/config_reader-gem/blob/master/README.rdoc
  EOS
end
