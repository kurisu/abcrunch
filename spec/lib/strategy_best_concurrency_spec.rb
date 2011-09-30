require 'spec_helper'

describe "RockHardAbs::StrategyBestConcurrency" do

  describe "#run" do
    before :each do
      @test_page = {
        :url => 'some url'
      }

      @fake_result_text = FAKE_AB_RESULT
      @fake_result = RockHardAbs::AbResult.new(@fake_result_text, @test_page)

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
      @test_page = {
        :url => 'some url'
      }

      @fake_result_text = FAKE_AB_RESULT
      @fake_result = RockHardAbs::AbResult.new(@fake_result_text, @test_page)

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

  FAKE_AB_RESULT = <<-ABRESULT
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.google.com (be patient).....done


Server Software:        gws
Server Hostname:        www.google.com
Server Port:            80

Document Path:          /
Document Length:        10372 bytes

Concurrency Level:      1
Time taken for tests:   0.880 seconds
Complete requests:      10
Failed requests:        8
   (Connect: 0, Receive: 0, Length: 8, Exceptions: 0)
Write errors:           0
Total transferred:      109542 bytes
HTML transferred:       103762 bytes
Requests per second:    11.36 [#/sec] (mean)
Time per request:       88.019 [ms] (mean)
Time per request:       88.019 [ms] (mean, across all concurrent requests)
Transfer rate:          121.54 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:       24   29   4.4     28      38
Processing:    56   59   3.2     59      66
Waiting:       52   55   3.4     55      64
Total:         80   88   6.4     88     103

Percentage of the requests served within a certain time (ms)
  50%     88
  66%     89
  75%     89
  80%     91
  90%    103
  95%    103
  98%    103
  99%    103
 100%    103 (longest request)
      ABRESULT

end