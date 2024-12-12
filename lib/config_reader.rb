require "config_reader/version"
require "config_reader/config_hash"
require "psych"

begin
  require "erb"
rescue LoadError
  warn "ERB not found, you won't be able to use ERB in your config"
end

class ConfigReader
  class << self
    attr_reader :envs

    def [](key)
      config[key.to_sym]
    end

    def config
      @config = nil unless defined?(@config)
      @config ||= reload
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def deep_merge(hash, other_hash)
      hash.merge!(other_hash) do |key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          deep_merge(this_val, other_val)
        else
          other_val
        end
      end
    end

    def dig(*args)
      args.map!(&:to_sym) if args.respond_to?(:map!)

      config.dig(*args)
    end

    def find_config
      return configuration.config_file if File.exist?(configuration.config_file)

      %w[. config].each do |dir|
        config_file = File.join(dir, configuration.config_file)
        return config_file if File.exist?(config_file)
      end

      nil
    end

    def inspect
      puts config.inspect
    end

    def load_config
      raise "No config file set" unless find_config

      conf =
        if defined?(ERB)
          Psych.load(ERB.new(File.read(find_config)).result, aliases: true)
        else
          Psych.load_file(File.read(find_config), aliases: true)
        end

      raise "No config found" unless conf

      conf
    end

    def load_sekrets
      sekrets = {}

      if configuration.sekrets_file
        begin
          require "sekrets"
          sekrets = ::Sekrets.settings_for(configuration.sekrets_file)
          raise "No sekrets found" unless sekrets
        rescue LoadError
          warn "You specified a sekrets_file, but the sekrets gem isn't available."
        end
      end

      sekrets
    end

    def merge_configs(conf, sekrets)
      @envs = {}
      env_keys = conf.keys - ["defaults"]
      env = configuration.environment

      defaults = conf["defaults"]

      if sekrets && sekrets["defaults"]
        defaults = deep_merge(defaults, sekrets["defaults"])
      end

      env_keys.each do |key|
        key_hash = deep_merge(defaults, conf[key]) if conf[key]
        key_hash = deep_merge(defaults, sekrets[key]) if sekrets && sekrets[key]

        @envs[key] = ConfigHash.convert_hash(
          key_hash,
          configuration.ignore_missing_keys
        )
      end

      @envs[env]
    end

    def method_missing(key, *_args, &_block)
      if key.to_s.end_with?("=")
        raise ArgumentError.new("ConfigReader is immutable")
      end

      config[key] || nil
    end

    def reload
      merge_configs(load_config, load_sekrets)
    end

    def respond_to_missing?(m, *)
      config.key?(m)
    end
  end

  class Configuration
    attr_accessor :config_file,
                  :sekrets_file,
                  :ignore_missing_keys,
                  :environment

    def initialize
      @config_file = nil
      @sekrets_file = nil
      @ignore_missing_keys = false
      @environment = nil
    end
  end
end
