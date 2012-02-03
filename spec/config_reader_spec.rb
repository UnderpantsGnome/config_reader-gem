require 'spec_helper'

describe "ConfigReader" do
  describe "parsing a YAML file" do
    it "should find values with method_missing" do
      TestConfig.app_name.should == 'default_app'
    end

    it "should find values using [] and a string" do
      TestConfig['app_name'].should == 'default_app'
    end

    it "should find values using [] and a symbol" do
      TestConfig[:app_name].should == 'default_app'
    end

    it "should find nested values using using method_missing" do
      TestConfig.nested_key.value.should == 'test'
    end

    it "should find nested values using [] and a symbol" do
      TestConfig[:nested_key][:value].should == 'test'
    end

    it "should find nested values using [] and a string" do
      TestConfig['nested_key']['value'].should == 'test'
    end
  end
end
