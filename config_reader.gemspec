$:.push File.expand_path("../lib", __FILE__)
require "config_reader/version"

Gem::Specification.new do |s|
  s.name = "config_reader"
  s.version = ConfigReader::VERSION
  s.authors = ["Michael Moen"]
  s.email = ["michael@underpantsgnome.com"]
  s.homepage = "https://github.com/UnderpantsGnome/config_reader-gem"
  s.summary =
    "Provides a way to manage environment specific configuration settings."
  s.description =
    "Provides a way to manage environment specific configuration settings."

  s.files = `git ls-files`.split("\n")
  s.executables =
    `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "abbrev", ">= 0"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.9"
  s.add_development_dependency "sekrets", "~> 1.14"
  s.add_development_dependency "pry"

  s.post_install_message = <<~EOS
    If you are are upgrading from a pre 2.x version,
    please see the configuration changes in the
    README https://github.com/UnderpantsGnome/config_reader-gem/blob/master/README.rdoc
  EOS
end
