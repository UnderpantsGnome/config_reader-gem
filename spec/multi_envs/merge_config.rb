class MergeConfig < ConfigReader
  configure do |config|
    config.environment = "merge"
    config.config_file = "spec/multi_envs/merge_config.yml"
  end
end
