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
      hash.merge(other_hash) do |_key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          deep_merge(this_val, other_val)
        else
          other_val
        end
      end
    end

    def dig_path(path, separator: ".")
      dig(*parse_path(path, separator: separator))
    end

    def dig(*args)
      if args.respond_to?(:map!)
        args.map! do |arg|
          (arg.respond_to?(:to_sym) && !arg.is_a?(Integer)) ? arg.to_sym : arg
        end
      end

      config.dig(*args)
    end

    def parse_path(path, separator: ".")
      case path
      when String
        raise ArgumentError, "Path must not be blank" if path.strip.empty?

        path.split(separator).map { |segment| normalize_string_path_segment(segment) }
      when Array
        path.map { |segment| normalize_array_path_segment(segment) }
      else
        raise ArgumentError, "Path must be a String or Array"
      end
    end

    def find_config
      return nil unless configuration.config_file

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
        if sekrets_available?
          ::Sekrets.settings_for(configuration.sekrets_file) ||
            raise("No sekrets found")
        else
          raise ArgumentError,
                "You specified a sekrets_file, but the sekrets gem isn't available."
        end
      end
    end

    def sekrets_available?
      return true if defined?(::Sekrets)

      require "sekrets"
      true
    rescue LoadError
      false
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
          find_config,
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
      raise "No defaults config found" unless defaults

      if sekrets&.[]("defaults")
        defaults = deep_merge(defaults, sekrets["defaults"])
      end

      merge_all_configs(conf, defaults, sekrets)

      @envs[configuration.environment] ||
        raise("No config found for environment \"#{configuration.environment}\"")
    end

    def method_missing(key, *_args, &_block)
      if key.to_s.end_with?("=")
        raise ArgumentError.new("ConfigReader is immutable")
      end

      config[key]
    end

    def reload
      @config = merge_configs(load_config, load_sekrets)
    end

    def respond_to_missing?(m, include_private = false)
      super || config.key?(m)
    end

    def normalize_array_path_segment(segment)
      if segment.is_a?(String) || segment.is_a?(Symbol)
        segment.to_sym
      elsif segment.is_a?(Integer)
        segment
      else
        raise ArgumentError, "Path segments must be Strings, Symbols, or Integers"
      end
    end

    def normalize_string_path_segment(segment)
      if segment.is_a?(String) && segment.match?(/\A\d+\z/)
        segment.to_i
      else
        normalize_array_path_segment(segment)
      end
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
