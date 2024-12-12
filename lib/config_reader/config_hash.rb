class ConfigReader
  class ConfigHash < Hash
    attr_accessor :ignore_missing_keys

    def self.convert_hash(hash, ignore_missing_keys = false)
      config_hash = new
      config_hash.ignore_missing_keys = ignore_missing_keys

      hash.each_pair do |key, value|
        config_hash[key.to_sym] = if value.is_a?(Hash)
          convert_hash(value, ignore_missing_keys)
        else
          value
        end
      end

      config_hash
    end

    def [](key)
      fetch(key.to_sym)
    rescue KeyError => e
      raise e unless ignore_missing_keys
    end

    def method_missing(key, *args, &block)
      key?(key) ? fetch(key) : super
    rescue KeyError, NoMethodError => e # skipcq: RB-P1001
      raise e unless ignore_missing_keys
    end

    def respond_to_missing?(m, *)
      config.key?(m)
    end
  end
end
