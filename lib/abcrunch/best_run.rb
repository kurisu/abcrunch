module AbCrunch
  class BestRun
    def self.of_avg_response_time(num_runs, ab_options)
      AbCrunch::Logger.log :task, "Best of #{num_runs} runs at concurrency: #{ab_options[:concurrency]} and num_requests: #{ab_options[:num_requests]}"
      AbCrunch::Logger.log :info, "for #{AbCrunch::Page.get_url(ab_options)}"
      AbCrunch::Logger.log :info, "Collecting average response times for each run:"

      min_response_time = 999999
      min_response_result = nil
      num_runs.times do
        abr = AbCrunch::AbRunner.ab(ab_options)
        AbCrunch::Logger.log :info, "Average response time: #{abr.avg_response_time} (ms) "
        if abr.avg_response_time < min_response_time
          min_response_time = abr.avg_response_time
          min_response_result = abr
        end
      end
      AbCrunch::Logger.log :progress, "Best response time was #{min_response_time}"
      min_response_result
    end
  end
end