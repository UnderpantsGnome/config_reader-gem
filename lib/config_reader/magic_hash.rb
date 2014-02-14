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

    ## Dont throw any error 
    def [](key)
      super(key.to_sym)
    end
    
    ## Let everything key added in future  be a symbol
    def []=(key,value)
      super(key.to_sym,value)
    end  

    def method_missing(key)
      has_key?(key) ? fetch(key) : super
    end
  end
end
