require 'spec_helper'

describe "AbRunner" do
  describe "#validate_options" do
    it "should throw an error when no url is provided" do
      lambda {
        AbCrunch::AbRunner.validate_options({})
      }.should raise_error "AB Options missing :url"
    end

    it "should return the options merged into the global configuration's ab_options'" do
      result = AbCrunch::AbRunner.validate_options({:url => 'some url'})
      result.should == AbCrunch::Config.ab_options.merge({:url => 'some url'})
    end
  end

  describe "#ab_command" do
    it "should return the ab command line based on given options" do
      options = {
        :concurrency => 'thigh master',
        :num_requests => 'i can only do 5 today',
        :url => '5 minute abs'
      }
      AbCrunch::AbRunner.ab_command(options).should == 'ab -c thigh master -n i can only do 5 today 5 minute abs'
    end
  end

  describe "#ab" do
    it "should run ab and wrap the results in an ab result" do
      def Open3.block=(block) ; @block = block ; end
      def Open3.block(cmd, &block)
        self.block = block if block_given?
        block.call(StringIO.new(''), StringIO.new('some fake output'), StringIO.new(''))
        return(@block)
      end
      Open3.block = nil
      stub(Open3).popen3.implemented_by(Open3.method(:block))

      stub(AbCrunch::AbRunner).ab_command('bar') { 'foo' }
      mock(AbCrunch::AbResult).new('some fake output', 'bar') { 'six pack' }
      
      AbCrunch::AbRunner.ab('bar').should == 'six pack'
    end
  end
end