namespace :abcrunch do

  desc "Test example pages"
  task :example do
    AbCrunch::Config.page_sets = @sample_page_sets
    Rake::Task['abcrunch:sample_1'].invoke
  end

  @sample_page_sets = {
    :sample_1 => [
      {
        :name => "Google home page",
        :url => proc do
          "http://www.google.com/?q=#{['food','coma','weirds','code'][rand(4)]}"
        end,
        :min_queries_per_second => 10,
        :max_avg_response_time => 1000,
      },
      {
        :name => "Facebook home page",
        :url => "http://www.facebook.com/",
        :max_avg_response_time => 1000,
      },
      {
        :name => "Bing Homepage",
        :url => "http://www.bing.com/",
        :min_queries_per_second => 50,
        :max_avg_response_time => 200
      }
    ]
  }

end
