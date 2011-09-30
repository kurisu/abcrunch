require 'spec_helper'

describe "RockHardAbs::StrategyBestConcurrency" do

  describe "#run" do
    before :each do
      @test_page = RockHardAbsSpec.new_page
      @fake_result = RockHardAbsSpec.new_result

      stub(RockHardAbs::BestRun).of_avg_response_time { @fake_result }
      stub(RockHardAbs::StrategyBestConcurrency).find_best_concurrency { @fake_result }
      stub(RockHardAbs::Logger).log
    end

    it "should get the baseline using the global options merged with the page" do
      page = RockHardAbs::Config.best_concurrency_options.merge(@test_page)
      mock(RockHardAbs::BestRun).of_avg_response_time(page[:num_baseline_runs], page)

      RockHardAbs::StrategyBestConcurrency.run(@test_page)
    end

    it "should use page option overrides" do
      in_page = @test_page.merge({:num_baseline_runs => 17})
      expected_page = RockHardAbs::Config.best_concurrency_options.merge(in_page)
      mock(RockHardAbs::BestRun).of_avg_response_time(17, expected_page) {@fake_result}
      proxy(RockHardAbs::Config.best_concurrency_options).merge(in_page)

      RockHardAbs::StrategyBestConcurrency.run(in_page)
    end

    it "should find the max concurrency" do
      expected_page = RockHardAbs::Config.best_concurrency_options.merge(@test_page)
      mock(RockHardAbs::StrategyBestConcurrency).find_best_concurrency(expected_page, @fake_result) {@fake_result}

      RockHardAbs::StrategyBestConcurrency.run(@test_page)
    end
  end

  describe "#calc_threshold" do
    describe "when max latency is higher than the base response time plus the percent margin" do
      it "should return the base response time plus the percent margin" do
        RockHardAbs::StrategyBestConcurrency.calc_threshold(100, 0.2, 200).should == 120.0
      end
    end
    describe "when max latency is lower than the base response time plus the percent margin" do
      it "should return the max latency" do
        RockHardAbs::StrategyBestConcurrency.calc_threshold(190, 0.2, 200).should == 200.0
      end
    end
  end
  
  describe "#find_best_concurrency" do
    before :each do
      @test_page = RockHardAbsSpec.new_page
      @fake_result = RockHardAbsSpec.new_result

      stub(RockHardAbs::Logger).log
    end

    it "should return the ab result for the run with the highest concurrency before response time degrades" do
      input_page = RockHardAbs::Config.best_concurrency_options.merge(@test_page).merge({:num_concurrency_runs => 3})
      test_page_1 = input_page.clone.merge({:concurrency => 1})
      test_result_1 = @fake_result.clone
      test_result_1.ab_options = test_page_1

      test_page_2 = input_page.clone.merge({:concurrency => 2})
      test_result_2 = @fake_result.clone
      test_result_2.ab_options = test_page_2

      test_page_3 = input_page.clone.merge({:concurrency => 3})
      desired_result = @fake_result.clone
      desired_result.ab_options = test_page_3
      stub(desired_result).avg_response_time { 90.3 }

      test_page_4 = input_page.clone.merge({:concurrency => 4})
      degraded_result = @fake_result.clone
      degraded_result.ab_options = test_page_4
      stub(degraded_result).avg_response_time { 9999.3 }

      stub(RockHardAbs::BestRun).of_avg_response_time(3, test_page_1) { test_result_1 }
      stub(RockHardAbs::BestRun).of_avg_response_time(3, test_page_2) { test_result_2 }
      stub(RockHardAbs::BestRun).of_avg_response_time(3, test_page_3) { desired_result }
      stub(RockHardAbs::BestRun).of_avg_response_time(3, test_page_4) { degraded_result }

      result = RockHardAbs::StrategyBestConcurrency.find_best_concurrency(input_page, @fake_result)

      result.ab_options[:concurrency].should == 3
      result.avg_response_time.should == 90.3
      result.should == desired_result
    end
  end

end