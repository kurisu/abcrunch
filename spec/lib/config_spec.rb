require 'spec_helper'

describe "AbCrunch::Config" do
  it "should have hashes for ab options and max concurrent options" do
    AbCrunch::Config.best_concurrency_options.class.to_s.should == 'Hash'
    AbCrunch::Config.ab_options.class.to_s.should == 'Hash'
  end

  it "should have a hash for the pages to be tested" do
    AbCrunch::Config.page_sets.class.to_s.should == 'Hash'
  end

  describe "#page_sets=" do
    it "should remember the new page sets and force new rake tasks to be created" do
      mock(AbCrunch::Config).load(File.join(AbCrunch.root, "lib/abcrunch/tasks/generated.rake"))

      AbCrunch::Config.page_sets = { :foo => 'bar' }

      AbCrunch::Config.page_sets.should == { :foo => 'bar' }
    end
  end
end