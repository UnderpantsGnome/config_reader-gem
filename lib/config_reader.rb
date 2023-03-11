require 'config_reader/version'
require 'config_reader/magic_hash'
require 'yaml'

begin
  require 'erb'
rescue LoadError
  puts "ERB not found, you won't be able to use ERB in your config"
end

class ConfigReader
  class << self
    attr_accessor :configuration

    def config
      @config = nil unless defined?(@config)
      @config ||= reload
    end

    def reload
      merge_configs(load_config, load_sekrets)
    end

    def [](key)
      config[key.to_sym]
    end

    def find_config
      return configuration.config_file if File.exist?(configuration.config_file)

      %w( . config ).each do |dir|
        config_file = File.join(dir, configuration.config_file)
        return config_file if File.exist?(config_file)
      end

      nil
    end

    def method_missing(key, *args, &block)
      if key.to_s.end_with?('=')
        raise ArgumentError.new('ConfigReader is immutable')
      end

      config[key] || nil
    end

    def inspect
      puts config.inspect
    end

    def load_config
      raise 'No config file set' unless find_config

      if defined?(ERB)
        conf = YAML.load(ERB.new(File.open(find_config).read).result)
      else
        conf = YAML.load(File.open(find_config).read)
      end

      raise 'No config found' unless conf

      conf
    end

    def load_sekrets
      sekrets = {}

      if configuration.sekrets_file
        begin
          require 'sekrets'
          sekrets = ::Sekrets.settings_for(configuration.sekrets_file)
          raise 'No sekrets found' unless sekrets
        rescue LoadError
          $stderr.puts "You specified a sekrets_file, but the sekrets gem isn't available."
        end
      end

      sekrets
    end

    def merge_configs(conf, sekrets)
      env = configuration.environment

      _conf = conf['defaults']
      deep_merge!(_conf, sekrets['defaults']) if sekrets && sekrets['defaults']
      deep_merge!(_conf, conf[env]) if conf[env]
      deep_merge!(_conf, sekrets[env]) if sekrets && sekrets[env]

      MagicHash.convert_hash(_conf, configuration.ignore_missing_keys)
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def deep_merge!(hash, other_hash)
      hash.merge!(other_hash) do |key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          deep_merge!(this_val, other_val)
        else
          other_val
        end
      end
    end
  end

  class Configuration
    attr_accessor :config_file, :sekrets_file, :ignore_missing_keys, :environment

    def initialize
      @config_file = nil
      @sekrets_file = nil
      @ignore_missing_keys = false
      @environment = nil
    end
  end

end
