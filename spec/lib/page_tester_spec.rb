require 'spec_helper'

describe "RockHardAbs::PageTester" do
  describe "#test" do
    before :each do
      @test_page = RockHardAbsSpec.new_page
      @test_result = RockHardAbsSpec.new_result
      @strategies = [RockHardAbs::StrategyBestConcurrency]

      stub(RockHardAbs::Logger).log
    end

    it "should run every load testing strategy on the given page" do
      @strategies.each do |strategy|
        mock(strategy).run(@test_page) { @test_result }
      end

      RockHardAbs::PageTester.test(@test_page)
    end

    def stub_strategies(result = nil)
      strategy_result = result ? result : RockHardAbsSpec.new_result

      @strategies.each do |strategy|
        stub(strategy).run { strategy_result }
      end
    end

    it "should use any user provided max avg response time as the max latency for all strategies" do
      stub_strategies
      page = RockHardAbsSpec.new_page({:max_avg_response_time => 139.2})

      RockHardAbs::PageTester.test(page)

      page[:max_latency].should == 139.2
    end

    it "should fail if the avg response time is over the specified maximum" do
      result = RockHardAbsSpec.new_result
      class << result
        def avg_response_time
          200
        end
      end
      page = RockHardAbsSpec.new_page({:max_avg_response_time => 117})

      stub_strategies(result)

      passed, qps_result, errors = RockHardAbs::PageTester.test(page)

      passed.should == false
      errors.should == [
        "some page: Avg response time of 200 must be <= 117"
      ]
    end

    it "should fail if the queries per second is under the specified minimum" do
      result = RockHardAbsSpec.new_result
      class << result
        def queries_per_second
          5
        end
      end
      page = RockHardAbsSpec.new_page({:min_queries_per_second => 117})

      stub_strategies(result)

      passed, qps_result, errors = RockHardAbs::PageTester.test(page)

      passed.should == false
      errors.should == [
        "some page: QPS of 5 must be >= 117"
      ]
    end
  end
end