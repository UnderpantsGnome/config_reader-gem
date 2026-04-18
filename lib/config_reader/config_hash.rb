class ConfigReader
  class ConfigHash < Hash
    attr_accessor :ignore_missing_keys

    def self.convert_hash(hash, ignore_missing_keys = false)
      config_hash = new
      config_hash.ignore_missing_keys = ignore_missing_keys

      hash.each_pair do |key, value|
        config_hash[key.to_sym] = convert_value(value, ignore_missing_keys)
      end

      config_hash
    end

    def self.convert_value(value, ignore_missing_keys = false)
      if value.is_a?(Hash)
        convert_hash(value, ignore_missing_keys)
      elsif value.is_a?(Array)
        value.map { |item| convert_value(item, ignore_missing_keys) }
      else
        value
      end
    end

    def [](key)
      key = key.to_sym if key.respond_to?(:to_sym)

      fetch(key)
    rescue KeyError => e
      raise e unless ignore_missing_keys
    end

    def method_missing(key, *args, &block)
      ignore_missing_keys ? self[key] : fetch(key)
    end

    def respond_to_missing?(m, *)
      key?(m)
    end
  end
end
