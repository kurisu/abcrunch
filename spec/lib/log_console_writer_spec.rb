require 'spec_helper'

describe "RockHardAbs::LogConsoleWriter" do
  describe "#color_for_type" do
    it "should return the color for the given type" do
      RockHardAbs::LogConsoleWriter.color_for_type(:progress).should == :green
    end

    describe "when the type is unknown" do
      it "should return white" do
        RockHardAbs::LogConsoleWriter.color_for_type(:weasel).should == :white
      end
    end
  end

  describe "#prefix_for_type" do
    it "should return the prefix for the given type" do
      RockHardAbs::LogConsoleWriter.prefix_for_type(:progress).should == '  '
    end

    describe "when the type is unknown" do
      it "should return an empty string" do
        RockHardAbs::LogConsoleWriter.prefix_for_type(:weasel).should == ''
      end
    end
  end

  describe "#log" do
    describe "inline behavior" do
      before :each do
        @calls = []
        @messages = []
        stub(RockHardAbs::LogConsoleWriter).print do |msg|
          @calls << 'print'
          @messages << msg
        end
        stub(RockHardAbs::LogConsoleWriter).puts do |msg|
          @calls << 'puts'
          @messages << msg
        end
      end

      describe "when the message is intended to be inline" do
        it "should print instead of puts" do
          RockHardAbs::LogConsoleWriter.log(:info, 'foo', {:inline => true})

          @calls.should == ['print']
        end
      end

      describe "when the message is NOT intended to be inline" do
        it "should puts instead of print" do
          RockHardAbs::LogConsoleWriter.log(:info, 'foo')

          @calls.should == ['puts']
        end
      end

      describe "when the previous message was inline, and the current one is not" do
        it "should prepend a new line" do
          RockHardAbs::LogConsoleWriter.log(:info, 'foo', {:inline => true})
          RockHardAbs::LogConsoleWriter.log(:info, 'foo')

          @messages[1].should include "\n  foo"
        end
      end
    end

    describe "if the type has a color" do
      it "should should invoke the color on the message" do
        calls = []
        any_instance_of(String) do |s|
          stub(s).green { calls << 'green' }
        end

        RockHardAbs::LogConsoleWriter.log(:progress, 'foo')

        calls.should == ['green']
      end
    end
  end
end