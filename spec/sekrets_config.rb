class SekretsConfig < ConfigReader
  self.config_file = 'spec/test_config.yml'
  self.sekrets_file = 'spec/sekrets_config.yml.enc'
end
