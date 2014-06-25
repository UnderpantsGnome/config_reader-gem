class ConfigReader
  class MagicHash < Hash

    def self.convert_hash(hash)
      magic_hash = new

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
      fetch(key.to_sym)
    end

    def method_missing(key, *args, &block)
      has_key?(key) ?
        fetch(key) :
        super
    end

  end
end
