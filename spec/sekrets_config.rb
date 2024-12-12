class SekretsConfig < ConfigReader
  secret_file = "spec/sekrets_config.yml.enc"

  configure do |config|
    config.environment = "test"
    config.config_file = "spec/test_config.yml"
    config.sekrets_file = secret_file
  end
end
