class ConfigReader
  class MagicHash < Hash
    attr_accessor :ignore_missing_keys

    def self.convert_hash(hash, ignore_missing_keys=false)
      magic_hash = new
      magic_hash.ignore_missing_keys = ignore_missing_keys

      hash.each_pair do |key, value|
        if value.is_a?(Hash)
          magic_hash[key.to_sym] = convert_hash(value)
        else
          magic_hash[key.to_sym] = value
        end
      end

      magic_hash
    end

    def [](key)
      begin
        fetch(key.to_sym)
      rescue KeyError => e
        raise e unless @ignore_missing_keys
      end
    end

    def method_missing(key, *args, &block)
      begin
        has_key?(key) ?
          fetch(key) :
          super
      rescue KeyError => e
        raise e unless @ignore_missing_keys
      end
    end

  end
end
