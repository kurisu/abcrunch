require 'spec_helper'

describe "BestRun" do
  before :all do
    @ab_options = {
      :url => 'foo',
      :concurrency => 1,
      :num_requests => 10
    }
  end

  describe "#of_avg_response_time" do
    it "should run ab on the ab options N times" do
      stub(AbCrunch::Logger).log
      num_runs = 0
      stub(AbCrunch::AbRunner).ab(@ab_options) do
        num_runs += 1
        obj = "foo"

        class << obj
          def avg_response_time
            4
          end
        end
        obj
      end

      AbCrunch::BestRun.of_avg_response_time(7, @ab_options)

      num_runs.should == 7
    end

    it "should return the ab result for the run with the lowest avg response time" do
      stub(AbCrunch::Logger).log
      response_times = [3, 87, 1, 590]

      run_idx = 0
      stub(AbCrunch::AbRunner).ab(@ab_options) do
        obj = Object.new
        response_time = response_times[run_idx]
        obj.singleton_class.class_eval do
          define_method(:avg_response_time) do
            response_time
          end
        end

        run_idx += 1
        obj
      end

      result = AbCrunch::BestRun.of_avg_response_time(4, @ab_options)

      result.avg_response_time.should == 1
    end
  end
end