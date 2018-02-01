class SekretsConfig < ConfigReader
  configure do |config|
    config.environment = 'test'
    config.config_file = 'spec/test_config.yml'
    config.sekrets_file = 'spec/sekrets_config.yml.enc'
  end
end
