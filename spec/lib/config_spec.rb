require 'spec_helper'

describe "AbCrunch::Config" do
  it "should have hashes for ab options and max concurrent options" do
    AbCrunch::Config.best_concurrency_options.class.to_s.should == 'Hash'
    AbCrunch::Config.ab_options.class.to_s.should == 'Hash'
  end

  it "should have a hash for the pages to be tested" do
    AbCrunch::Config.page_sets.class.to_s.should == 'Hash'
  end
end