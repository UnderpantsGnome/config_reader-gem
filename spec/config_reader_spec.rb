require File.dirname(__FILE__) + '/spec_helper.rb'

describe "ConfigReader" do
  it "should parse a YAML config" do
    TestConfig.app_name.should == 'default_app'
  end
  
  it "should support nested keys" do
    TestConfig.nested_key.value.should == 'test'
  end
  
  # it "should use the APP_ENV environment variable" do
  #   system 'export APP_ENV=test'
  #   TestConfig.app_name.should == 'test_app'
  # end
end
