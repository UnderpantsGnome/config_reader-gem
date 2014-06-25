require "config_reader/version"
require "config_reader/magic_hash"
require 'yaml'

begin
  require 'erb'
rescue LoadError
  puts "ERB not found, you won't be able to use ERB in your config"
end

class ConfigReader
  class << self
    attr_accessor :config_file, :config, :sekrets_file

    def config
      @config = nil unless defined?(@config)
      @config ||= reload
    end

    def config_file=(file)
      @config_file = file
    end

    def reload
      merge_configs(find_env, load_config, load_sekrets)
    end

    def [](key)
      config[key.to_sym]
    end

    def find_config
      return @config_file if File.exist?(@config_file)

      %w( . config ).each do |dir|
        config_file = File.join(dir, @config_file)
        return config_file if File.exist?(config_file)
      end

      ''
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

    def find_env
      if defined?(Rails) && Rails.stage
        Rails.stage
      elsif defined?(Rails) && Rails.env
        Rails.env
      elsif defined?(RAILS_ENV)
        RAILS_ENV
      elsif defined?(Padrino) && Padrino.env
        Padrino.env.to_s
      elsif defined?(PADRINO_ENV)
        PADRINO_ENV
      elsif ENV['RACK_ENV']
        ENV['RACK_ENV']
      elsif defined?(APP_ENV)
        APP_ENV
      end
    end

    def load_config
      raise 'No config file set' unless @config_file

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

      if @sekrets_file
        begin
          require 'sekrets'
          sekrets = ::Sekrets.settings_for(@sekrets_file)
          raise 'No sekrets found' unless sekrets
        rescue LoadError
          $stderr.puts "You specified a sekrets_file, but the sekrets gem isn't available."
        end
      end

      sekrets
    end

    def merge_configs(env, conf, sekrets)
      _conf = conf['defaults']
      _conf.merge!(sekrets['defaults']) if sekrets && sekrets['defaults']
      _conf.merge!(conf[env]) if conf[env]
      _conf.merge!(sekrets[env]) if sekrets && sekrets[env]
      ConfigReader::MagicHash.convert_hash(_conf)
    end
  end
end
