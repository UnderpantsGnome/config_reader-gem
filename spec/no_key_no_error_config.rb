class NoKeyNoErrorConfig < ConfigReader
  configure do |config|
    config.environment = "test"
    config.config_file = "spec/test_config.yml"
    config.ignore_missing_keys = true
  end
end
