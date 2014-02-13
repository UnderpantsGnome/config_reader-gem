require "config_reader/version"
require "config_reader/magic_hash"
require 'yaml'

begin
  require 'erb'
rescue LoadError
  puts "ERB not found, you won't be able to use ERB in your config"
end

class ConfigReader
  @config_file = nil
  @config = nil

  class << self
    def config
      @config = nil unless defined?(@config)
      @config ||= reload
    end

    def config_file=(file)
      @config_file = file
    end

    def reload
      raise 'No config file set' unless @config_file

      if defined?(ERB)
        conf = YAML.load(ERB.new(File.open(find_config).read).result)
      else
        conf = YAML.load(File.open(find_config).read)
      end

      raise 'No config found' unless conf

      if defined?(Rails) and Rails.env
        env = Rails.env
      elsif defined?(RAILS_ENV)
        env = RAILS_ENV
      elsif defined?(Padrino) and Padrino.env
        env = Padrino.env
      elsif defined?(PADRINO_ENV)
        env = PADRINO_ENV
      elsif ENV['RACK_ENV']
        env = ENV['RACK_ENV']
      elsif defined?(APP_ENV)
        env = APP_ENV
      end

      _conf = conf['defaults']
      _conf.merge!(conf[env]) if conf[env]
      ConfigReader::MagicHash.convert_hash(_conf)
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

    def method_missing(key)
      config[key] || nil
    end

    def inspect
      puts config.inspect
    end
  end
end
