require 'spec_helper'

describe "AbCrunch::PageTester" do
  describe "#test" do

    def stub_strategies(result = nil)
      strategy_result = result ? result : AbCrunchSpec.new_result

      @strategies.each do |strategy|
        stub(strategy).run { strategy_result }
      end
    end

    before :each do
      @test_page = AbCrunchSpec.new_page
      @test_result = AbCrunchSpec.new_result
      @strategies = [AbCrunch::StrategyBestConcurrency]

      stub(AbCrunch::Logger).log
    end

    it "should show the display url" do
      stub_strategies

      mock(AbCrunch::Page).get_display_url(@test_page)

      AbCrunch::PageTester.test(@test_page)
    end

    it "should run every load testing strategy on the given page" do
      @strategies.each do |strategy|
        mock(strategy).run(@test_page) { @test_result }
      end

      AbCrunch::PageTester.test(@test_page)
    end

    it "should use any user provided max avg response time as the max latency for all strategies" do
      stub_strategies
      page = AbCrunchSpec.new_page({:max_avg_response_time => 139.2})

      AbCrunch::PageTester.test(page)

      page[:max_latency].should == 139.2
    end

    it "should fail if the avg response time is over the specified maximum" do
      result = AbCrunchSpec.new_result
      class << result
        def avg_response_time
          200
        end
      end
      page = AbCrunchSpec.new_page({:max_avg_response_time => 117})

      stub_strategies(result)

      passed, qps_result, errors = AbCrunch::PageTester.test(page)

      passed.should == false
      errors.should == [
        "some page: Avg response time of 200 must be <= 117"
      ]
    end

    it "should fail if the queries per second is under the specified minimum" do
      result = AbCrunchSpec.new_result
      class << result
        def queries_per_second
          5
        end
      end
      page = AbCrunchSpec.new_page({:min_queries_per_second => 117})

      stub_strategies(result)

      passed, qps_result, errors = AbCrunch::PageTester.test(page)

      passed.should == false
      errors.should == [
        "some page: QPS of 5 must be >= 117"
      ]
    end
  end
end