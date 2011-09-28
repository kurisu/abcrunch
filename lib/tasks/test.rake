namespace :test do
  desc "Test getting a best run"
  task 'best_run' do
    ab_options = {
      :url => 'http://clearbook.truecar.com/',
      :concurrency => 1,
      :num_requests => 10
    }
    RockHardAbs::BestRun.of_avg_response_time 5, ab_options
  end

  desc "Test strategy: QPS at best concurrency"
  task 'qps_concurrency' do
    RockHardAbs::StrategyQpsAtBestConcurrency.run('http://www.truecar.com/')
  end

end