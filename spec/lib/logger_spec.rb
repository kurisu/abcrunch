require 'spec_helper'

describe "RockHardAbs::Logger" do
  describe "#log" do
    it "should call log on all writers" do
      RockHardAbs::Logger.writers = [RockHardAbs::LogConsoleWriter]
      mock(RockHardAbs::LogConsoleWriter).log(:foo, 'bar', {:bizz => 'bazam!'})

      RockHardAbs::Logger.log(:foo, 'bar', {:bizz => 'bazam!'})
    end
  end
end