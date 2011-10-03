require 'spec_helper'

describe "AbCrunch::Logger" do
  describe "#log" do
    it "should call log on all writers" do
      AbCrunch::Logger.writers = [AbCrunch::LogConsoleWriter]
      mock(AbCrunch::LogConsoleWriter).log(:foo, 'bar', {:bizz => 'bazam!'})

      AbCrunch::Logger.log(:foo, 'bar', {:bizz => 'bazam!'})
    end
  end
end