require "spec_helper"

describe "ConfigReader" do
  describe "setting values" do
    it "should fail with []=" do
      expect { TestConfig[:app_name] = "test_app" }.to raise_error(
        ArgumentError
      )
    end

    it "should fail with #key =" do
      expect { TestConfig.app_name = "test_app" }.to raise_error(ArgumentError)
    end
  end

  describe "default KeyNotFound behavior" do
    it "should raise on missing key with [] accessor" do
      expect { TestConfig[:no_key] }.to raise_error(KeyError)
    end

    it "should raise on missing key with #key accessor" do
      expect { TestConfig.no_key }.to raise_error(KeyError)
    end

    it "should raise on missing nested key with [] accessor" do
      expect { TestConfig[:nested_key][:missing] }.to raise_error(KeyError)
    end

    it "should raise on missing nested key with #key accessor" do
      expect { TestConfig.nested_key.missing }.to raise_error(KeyError)
    end
  end

  describe "all envs available" do
    it "should have all envs available" do
      TestConfig.reload
      expect(TestConfig.envs.keys).to eq(%w[defaults test not_test])
    end

    it "should have ConfigHash for all envs" do
      expect(TestConfig.envs["test"].app_name).to eq("test_app")
      expect(TestConfig.envs["not_test"].app_name).to eq("not_test_app")
    end
  end

  describe "#dig" do
    it "finds values as symbols" do
      expect(TestConfig.dig(*%i[nested_key value])).to eq("test")
    end

    it "finds values as strings" do
      expect(TestConfig.dig(*%w[nested_key value])).to eq("test")
    end
  end

  describe ".parse_path" do
    it "parses dotted paths into dig segments" do
      expect(TestConfig.parse_path("nested_key.value")).to eq(%i[nested_key value])
    end

    it "parses array indexes from dotted paths" do
      expect(TestConfig.parse_path("items.0.name")).to eq([:items, 0, :name])
    end

    it "normalizes array input" do
      expect(TestConfig.parse_path(["nested_key", :value, 0])).to eq(
        [:nested_key, :value, 0]
      )
    end

    it "rejects blank strings" do
      expect { TestConfig.parse_path("") }.to raise_error(
        ArgumentError,
        "Path must not be blank"
      )
    end

    it "rejects unsupported types" do
      expect { TestConfig.parse_path(Object.new) }.to raise_error(
        ArgumentError,
        "Path must be a String or Array"
      )
    end
  end

  describe ".dig_path" do
    it "digs through dotted paths" do
      expect(TestConfig.dig_path("nested_key.value")).to eq("test")
    end

    it "digs through arrays" do
      config_class = Class.new(ConfigReader) do
        class << self
          def reload
            ConfigReader::ConfigHash.convert_hash(
              "items" => [{ "name" => "first" }]
            )
          end
        end
      end

      expect(config_class.dig_path("items.0.name")).to eq("first")
    end

    it "allows array input for numeric-looking keys" do
      config_class = Class.new(ConfigReader) do
        class << self
          def reload
            ConfigReader::ConfigHash.convert_hash(
              "numeric_keys" => { "0" => "zero" }
            )
          end
        end
      end

      expect(config_class.dig_path([:numeric_keys, "0"])).to eq("zero")
    end
  end

  describe "ignoring KeyNotFound" do
    it "should not raise on missing key with [] accessor" do
      expect { NoKeyNoErrorConfig[:no_key] }.to_not raise_error
    end

    it "should not raise on missing key with #key accessor" do
      expect { NoKeyNoErrorConfig.no_key }.to_not raise_error
    end

    it "should not raise on missing nested key with [] accessor" do
      expect { NoKeyNoErrorConfig[:nested_key][:missing] }.to_not raise_error
    end

    it "should not raise on missing nested key with #key accessor" do
      expect { NoKeyNoErrorConfig.nested_key.missing }.to_not raise_error
    end
  end

  describe "method_missing" do
    it "handles respond_to?" do
      expect(TestConfig.respond_to?(:not_a_key)).to be_falsey
    end

    it "handles respond_to_missing?" do
      expect(TestConfig.respond_to_missing?(:not_a_key)).to be_falsey
    end
  end

  describe "parsing a YAML file" do
    it "should find values with method_missing" do
      expect(TestConfig.app_name).to eq("test_app")
    end

    it "should find values using [] and a string" do
      expect(TestConfig["app_name"]).to eq("test_app")
    end

    it "should find values using [] and a symbol" do
      expect(TestConfig[:app_name]).to eq("test_app")
    end

    it "should find nested values using method_missing" do
      expect(TestConfig.nested_key.value).to eq("test")
    end

    it "should find nested values using [] and a symbol" do
      expect(TestConfig[:nested_key][:value]).to eq("test")
    end

    it "should find nested values using [] and a string" do
      expect(TestConfig["nested_key"]["value"]).to eq("test")
    end

    it "should not find sekrets only nested values using method_missing" do
      expect { TestConfig.sekrets_only }.to raise_error(KeyError)
    end

    it "should not find sekrets only nested values using [] and a symbol" do
      expect { TestConfig[:sekrets_only][:value] }.to raise_error(KeyError)
    end

    it "should not find sekrets only nested values using [] and a string" do
      expect { TestConfig["sekrets_only"]["value"] }.to raise_error(KeyError)
    end
  end

  context "using sekrets" do
    describe "parsing a YAML file" do
      it "should find values with method_missing" do
        expect(SekretsConfig.app_name).to eq("test_app_sekret")
      end

      it "should find values using [] and a string" do
        expect(SekretsConfig["app_name"]).to eq("test_app_sekret")
      end

      it "should find values using [] and a symbol" do
        expect(SekretsConfig[:app_name]).to eq("test_app_sekret")
      end

      it "should find nested values using method_missing" do
        expect(SekretsConfig.nested_key.value).to eq("test_sekret")
      end

      it "should find nested values using [] and a symbol" do
        expect(SekretsConfig[:nested_key][:value]).to eq("test_sekret")
      end

      it "should find nested values using [] and a string" do
        expect(SekretsConfig["nested_key"]["value"]).to eq("test_sekret")
      end

      it "should find values that only exist in sekrets" do
        config_class = Class.new(ConfigReader) do
          class << self
            def load_config
              {
                "defaults" => { "app_name" => "default_app" },
                "test" => { "app_name" => "test_app" }
              }
            end

            def load_sekrets
              {
                "test" => {
                  "sekrets_only" => { "value" => "test_sekret_only" }
                }
              }
            end
          end

          configure do |config|
            config.environment = "test"
          end
        end

        expect(config_class.sekrets_only.value).to eq("test_sekret_only")
        expect(config_class[:sekrets_only][:value]).to eq("test_sekret_only")
        expect(config_class["sekrets_only"]["value"]).to eq("test_sekret_only")
      end

      it "shouldn't need to have all keys duplicated in the environment section" do
        expect(SekretsConfig.nested_key.only_in_test_env).to be true
      end
    end
  end

  describe "regressions" do
    it "does not load sekrets on a plain require" do
      ruby_code = <<~RUBY
        require "config_reader"
        abort("sekrets loaded") if defined?(::Sekrets)
      RUBY

      stdout, stderr, status = Open3.capture3(
        "bundle",
        "exec",
        "ruby",
        "-Ilib",
        "-e",
        ruby_code,
        chdir: File.expand_path("..", __dir__)
      )

      expect(status.success?).to be(true), stderr
      expect(stdout).to eq("")
    end

    it "returns false for existing false values via method access" do
      config_class = Class.new(ConfigReader) do
        class << self
          def reload
            ConfigReader::ConfigHash.convert_hash("feature_enabled" => false)
          end
        end
      end

      expect(config_class.feature_enabled).to be(false)
    end

    it "raises a clear error when config_file is not set" do
      config_class = Class.new(ConfigReader) do
        configure do |config|
          config.environment = "test"
        end
      end

      expect { config_class.load_config }.to raise_error("No config file set")
    end

    it "raises a clear error when the configured environment is missing" do
      config_class = Class.new(ConfigReader) do
        configure do |config|
          config.environment = "missing"
          config.config_file = "spec/test_config.yml"
        end
      end

      expect { config_class.reload }.to raise_error(
        'No config found for environment "missing"'
      )
    end

    it "loads YAML without ERB support" do
      config_class = Class.new(ConfigReader) do
        configure do |config|
          config.environment = "test"
          config.config_file = "spec/test_config.yml"
        end
      end

      hide_const("ERB")

      expect(config_class.load_yaml.dig("test", "app_name")).to eq("test_app")
    end

    it "supports arrays when digging through config values" do
      config_class = Class.new(ConfigReader) do
        class << self
          def reload
            ConfigReader::ConfigHash.convert_hash(
              "items" => [{ "name" => "first", "enabled" => false }]
            )
          end
        end
      end

      expect(config_class[:items][0][:name]).to eq("first")
      expect(config_class.dig(:items, 0, :name)).to eq("first")
      expect(config_class.dig("items", 0, "enabled")).to be(false)
    end

    it "raises a clear error when defaults are missing" do
      config_class = Class.new(ConfigReader) do
        class << self
          def load_config
            { "test" => { "app_name" => "test_app" } }
          end

          def load_sekrets
            nil
          end
        end

        configure do |config|
          config.environment = "test"
        end
      end

      expect { config_class.reload }.to raise_error("No defaults config found")
    end
  end
end
