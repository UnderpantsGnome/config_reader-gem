require 'spec_helper'

describe "ConfigReader" do
  describe "setting values" do

    it "should fail with []=" do
      expect {
        TestConfig[:app_name] = 'test_app'
      }.to raise_error
    end

    it "should fail with #key =" do
      expect {
        TestConfig.app_name = 'test_app'
      }.to raise_error
    end
  end

  describe "parsing a YAML file" do
    it "should find values with method_missing" do
      TestConfig.app_name.should == 'test_app'
    end

    it "should find values using [] and a string" do
      TestConfig['app_name'].should == 'test_app'
    end

    it "should find values using [] and a symbol" do
      TestConfig[:app_name].should == 'test_app'
    end

    it "should find nested values using method_missing" do
      TestConfig.nested_key.value.should == 'test'
    end

    it "should find nested values using [] and a symbol" do
      TestConfig[:nested_key][:value].should == 'test'
    end

    it "should find nested values using [] and a string" do
      TestConfig['nested_key']['value'].should == 'test'
    end

    it "should not find sekrets only nested values using method_missing" do
      lambda { TestConfig.sekrets_only }.should raise_error
    end

    it "should not find sekrets only nested values using [] and a symbol" do
      lambda { TestConfig[:sekrets_only][:value] }.should raise_error
    end

    it "should not find sekrets only nested values using [] and a string" do
      lambda { TestConfig['sekrets_only']['value'] }.should raise_error
    end

  end

  context 'using sekrets' do
    ENV['SEKRETS_KEY'] = 'shhh'

    describe "parsing a YAML file" do
      it "should find values with method_missing" do
        SekretsConfig.app_name.should == 'test_app_sekret'
      end

      it "should find values using [] and a string" do
        SekretsConfig['app_name'].should == 'test_app_sekret'
      end

      it "should find values using [] and a symbol" do
        SekretsConfig[:app_name].should == 'test_app_sekret'
      end

      it "should find nested values using method_missing" do
        SekretsConfig.nested_key.value.should == 'test_sekret'
      end

      it "should find nested values using [] and a symbol" do
        SekretsConfig[:nested_key][:value].should == 'test_sekret'
      end

      it "should find nested values using [] and a string" do
        SekretsConfig['nested_key']['value'].should == 'test_sekret'
      end

      it "should find sekrets only nested values using method_missing" do
        SekretsConfig.nested_key.value.should == 'test_sekret'
      end

      it "should find sekrets only nested values using [] and a symbol" do
        SekretsConfig[:nested_key][:value].should == 'test_sekret'
      end

      it "should find sekrets only nested values using [] and a string" do
        SekretsConfig['nested_key']['value'].should == 'test_sekret'
      end

      it "shouldn't need to have all keys duplicated in the environment section" do
        SekretsConfig.nested_key.only_in_test_env.should == true
      end
    end
  end
end
