require 'spec_helper'

describe "RockHardAbs::Config" do
  it "should have hashes for ab options and max concurrent options" do
    RockHardAbs::Config.max_con_options.class.to_s.should == 'Hash'
    RockHardAbs::Config.ab_options.class.to_s.should == 'Hash'
  end
end