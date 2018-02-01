class NoKeyNoErrorConfig < ConfigReader
  self.config_file = 'spec/test_config.yml'
  self.ignore_missing_keys = true
end
