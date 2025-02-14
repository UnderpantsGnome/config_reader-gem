require "config_reader/version"
require "config_reader/config_hash"
require "psych"

begin
  require "sekrets"
rescue LoadError
end

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
      hash.merge(other_hash) do |_key, this_val, other_val|
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
      config.inspect
    end

    def load_config
      raise "No config file set" unless find_config

      conf = load_yaml

      raise "No config found" unless conf

      conf
    end

    def load_sekrets
      if configuration.sekrets_file
        if !defined?(::Sekrets)
          raise ArgumentError,
                "You specified a sekrets_file, but the sekrets gem isn't available."
        else
          ::Sekrets.settings_for(configuration.sekrets_file) ||
            raise("No sekrets found")
        end
      end
    end

    def load_yaml
      permitted_classes = configuration.permitted_classes.to_a + [Symbol]

      if defined?(ERB)
        Psych.safe_load(
          ERB.new(File.read(find_config)).result,
          aliases: true,
          permitted_classes: permitted_classes
        )
      else
        Psych.safe_load_file(
          File.read(find_config),
          aliases: true,
          permitted_classes: permitted_classes
        )
      end
    end

    def merge_all_configs(conf, defaults, sekrets)
      @envs = {}

      conf.keys.each do |env|
        env_hash = deep_merge(defaults, conf[env] || {})
        env_hash = deep_merge(env_hash, sekrets[env] || {}) if sekrets

        @envs[env] = ConfigHash.convert_hash(
          env_hash,
          configuration.ignore_missing_keys
        )
      end
    end

    def merge_configs(conf, sekrets)
      defaults = conf["defaults"]

      if sekrets&.[]("defaults")
        defaults = deep_merge(defaults, sekrets["defaults"])
      end

      merge_all_configs(conf, defaults, sekrets)

      @envs[configuration.environment]
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
                  :environment,
                  :ignore_missing_keys,
                  :permitted_classes,
                  :sekrets_file

    def initialize
      @config_file = nil
      @environment = nil
      @ignore_missing_keys = false
      @permitted_classes = []
      @sekrets_file = nil
    end
  end
end
