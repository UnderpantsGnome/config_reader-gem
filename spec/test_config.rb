class TestConfig < ConfigReader
  configure do |config|
    config.environment = "test"
    config.config_file = "spec/test_config.yml"
  end
end
