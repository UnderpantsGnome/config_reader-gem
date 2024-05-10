class SekretsConfig < ConfigReader
  secret_file =
    if RUBY_VERSION > "3.0"
      "spec/sekrets_ruby_3_2.yml.enc"
    else
      "spec/sekrets_config.yml.enc"
    end

  configure do |config|
    config.environment = "test"
    config.config_file = "spec/test_config.yml"
    config.sekrets_file = secret_file
  end
end
