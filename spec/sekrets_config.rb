class SekretsConfig < ConfigReader
  secret_file = RUBY_VERSION > '3.1' ?
    'spec/sekrets_config.yml.enc' :
    'spec/sekrets_ruby_3_2.yml.enc'

  configure do |config|
    config.environment = 'test'
    config.config_file = 'spec/test_config.yml'
    config.sekrets_file = secret_file
  end
end
