require 'spec_helper'

describe "ConfigReader" do
  describe "setting values" do

    it "should fail with []=" do
      expect {
        TestConfig[:app_name] = 'test_app'
      }.to raise_error(ArgumentError)
    end

    it "should fail with #key =" do
      expect {
        TestConfig.app_name = 'test_app'
      }.to raise_error(ArgumentError)
    end
  end

  describe "default KeyNotFound behavior" do
    it "should raise on missing key with [] accessor" do
      expect {
        TestConfig[:no_key]
      }.to raise_error(KeyError)
    end

    it "should raise on missing key with #key accessor" do
      expect {
        TestConfig.no_key
      }.to raise_error(KeyError)
    end

    it "should raise on missing nested key with [] accessor" do
      expect {
        TestConfig[:nested_key][:missing]
      }.to raise_error(KeyError)
    end

    it "should raise on missing nested key with #key accessor" do
      expect {
        TestConfig.nested_key.missing
      }.to raise_error(NoMethodError)
    end
  end

  describe "ignoring KeyNotFound" do
    it "should not raise on missing key with [] accessor" do
      expect {
        NoKeyNoErrorConfig[:no_key]
      }.to_not raise_error
    end

    it "should not raise on missing key with #key accessor" do
      expect {
        NoKeyNoErrorConfig.no_key
      }.to_not raise_error
    end

    it "should not raise on missing nested key with [] accessor" do
      expect {
        NoKeyNoErrorConfig[:nested_key][:missing]
      }.to_not raise_error
    end

    it "should not raise on missing nested key with #key accessor" do
      expect {
        NoKeyNoErrorConfig.nested_key.missing
      }.to_not raise_error
    end
  end

  describe "parsing a YAML file" do
    it "should find values with method_missing" do
      expect(TestConfig.app_name).to eq('test_app')
    end

    it "should find values using [] and a string" do
      expect(TestConfig['app_name']).to eq('test_app')
    end

    it "should find values using [] and a symbol" do
      expect(TestConfig[:app_name]).to eq('test_app')
    end

    it "should find nested values using method_missing" do
      expect(TestConfig.nested_key.value).to eq('test')
    end

    it "should find nested values using [] and a symbol" do
      expect(TestConfig[:nested_key][:value]).to eq('test')
    end

    it "should find nested values using [] and a string" do
      expect(TestConfig['nested_key']['value']).to eq('test')
    end

    it "should not find sekrets only nested values using method_missing" do
      expect { TestConfig.sekrets_only }.to raise_error(KeyError)
    end

    it "should not find sekrets only nested values using [] and a symbol" do
      expect { TestConfig[:sekrets_only][:value] }.to raise_error(KeyError)
    end

    it "should not find sekrets only nested values using [] and a string" do
      expect { TestConfig['sekrets_only']['value'] }.to raise_error(KeyError)
    end

  end

  context 'using sekrets' do
    describe "parsing a YAML file" do
      it "should find values with method_missing" do
        expect(SekretsConfig.app_name).to eq('test_app_sekret')
      end

      it "should find values using [] and a string" do
        expect(SekretsConfig['app_name']).to eq('test_app_sekret')
      end

      it "should find values using [] and a symbol" do
        expect(SekretsConfig[:app_name]).to eq('test_app_sekret')
      end

      it "should find nested values using method_missing" do
        expect(SekretsConfig.nested_key.value).to eq('test_sekret')
      end

      it "should find nested values using [] and a symbol" do
        expect(SekretsConfig[:nested_key][:value]).to eq('test_sekret')
      end

      it "should find nested values using [] and a string" do
        expect(SekretsConfig['nested_key']['value']).to eq('test_sekret')
      end

      it "should find sekrets only nested values using method_missing" do
        expect(SekretsConfig.nested_key.value).to eq('test_sekret')
      end

      it "should find sekrets only nested values using [] and a symbol" do
        expect(SekretsConfig[:nested_key][:value]).to eq('test_sekret')
      end

      it "should find sekrets only nested values using [] and a string" do
        expect(SekretsConfig['nested_key']['value']).to eq('test_sekret')
      end

      it "shouldn't need to have all keys duplicated in the environment section" do
        expect(SekretsConfig.nested_key.only_in_test_env).to be true
      end
    end
  end
end
