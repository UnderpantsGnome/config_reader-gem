require "spec_helper"
require "multi_envs/merge_config"

describe "ConfigReader" do
  before(:all) { MergeConfig.reload }

  describe "all envs available" do
    it "should have all envs available" do
      expect(MergeConfig.envs.keys).to eq(%w[defaults test not_test merge])
    end

    it "should have ConfigHash for all envs" do
      expect(MergeConfig.envs["test"].app_name).to eq("test_app")
      expect(MergeConfig.envs["not_test"].app_name).to eq("not_test_app")
      expect(MergeConfig.envs["merge"]).to eq(MergeConfig.envs["defaults"])
    end
  end
end
