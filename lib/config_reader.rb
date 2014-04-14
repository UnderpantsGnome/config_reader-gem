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

      conf = if defined?(ERB)
        YAML.load(ERB.new(File.open(find_config).read).result)
      else
        YAML.load(File.open(find_config).read)
      end

      raise 'No config found' unless conf
      ## because Padrino.env return a symbol
      _conf = ConfigReader::MagicHash.convert_hash(conf)

      env = if defined?(Rails) and Rails.env
        Rails.env
      elsif defined?(RAILS_ENV)
        RAILS_ENV
      elsif defined?(Padrino) and Padrino.env
        Padrino.env
      elsif defined?(PADRINO_ENV)
        PADRINO_ENV
      elsif ENV['RACK_ENV']
        ENV['RACK_ENV']
      elsif defined?(APP_ENV)
        APP_ENV
      end

      _default_conf = _conf['defaults'] || {}
      _default_conf.merge(_conf[env] || {})
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
