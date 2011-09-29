require 'spec_helper'

describe "AbRunner" do
  describe "#ab_command" do
    it "should return the ab command line based on given options" do
      options = {
        :concurrency => 'thigh master',
        :num_requests => 'i can only do 5 today',
        :url => '5 minute abs'
      }
      RockHardAbs::AbRunner.ab_command(options).should == 'ab -c thigh master -n i can only do 5 today 5 minute abs'
    end
  end

  describe "#ab" do
    it "should run ab and wrap the results in an ab result" do
      stub(RockHardAbs::AbRunner).__double_definition_create__.call(:`) { "some fake output" }
      stub(RockHardAbs::AbRunner).ab_command('bar') { 'foo' }
      mock(RockHardAbs::AbResult).new('some fake output', 'bar') { 'six pack' }
      
      RockHardAbs::AbRunner.ab('bar').should == 'six pack'
    end
  end
end