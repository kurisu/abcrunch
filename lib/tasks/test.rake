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

  desc "Test page tester"
  task 'page' do
    page = {
      :name => "TrueCar home page",
      :url => "http://www.truecar.com/",
      :min_queries_per_second => 20,
      :max_avg_response_time => 200,
    }
    RockHardAbs::PageTester.test(page)
  end

  desc "Test multiple pages"
  task 'pages' do
    pages = [
    {
      :name => "TrueCar home page",
      :url => "http://www.truecar.com/",
      :min_queries_per_second => 20,
      :max_avg_response_time => 1000,
    },
    {
      :name => "ClearBook home page",
      :url => "http://clearbook.truecar.com/",
      :max_avg_response_time => 1000,
    },
    {
      :name => "Histogram Widget",
      :url => "https://widgets.qa.honk.com/wsj/histogram?pag_id=179&make=toyota&model=corolla&year=2010&body_type=sedan&zip=95101",
      :min_queries_per_second => 50,
      :max_avg_response_time => 200
    }
    ]

    RockHardAbs::Tester.test(pages)
  end

end