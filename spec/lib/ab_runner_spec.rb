require 'spec_helper'

describe "AbRunner" do
  describe "#validate_options" do
    it "should throw an error when no url is provided" do
      lambda {
        RockHardAbs::AbRunner.validate_options({})
      }.should raise_error "AB Options missing :url"
    end

    it "should return the options merged into the global configuration's ab_options'" do
      result = RockHardAbs::AbRunner.validate_options({:url => 'some url'})
      result.should == RockHardAbs::Config.ab_options.merge({:url => 'some url'})
    end
  end

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
      stub(RockHardAbs::AbRunner).__double_definition_create__.call(:`) do |cmd|
        cmd == 'foo' ? "some fake output" : "wrong!"
      end
      stub(RockHardAbs::AbRunner).ab_command('bar') { 'foo' }
      mock(RockHardAbs::AbResult).new('some fake output', 'bar') { 'six pack' }
      
      RockHardAbs::AbRunner.ab('bar').should == 'six pack'
    end
  end
end