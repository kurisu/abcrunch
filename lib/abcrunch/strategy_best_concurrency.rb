module AbCrunch
  class StrategyBestConcurrency

    def self.calc_threshold(baseline_latency, percent_buffer, max_latency)
      [max_latency, baseline_latency * (1 + percent_buffer)].min
    end

    def self.find_best_concurrency(page, baseline_result)
      threshold_ms = calc_threshold(baseline_result.avg_response_time, page[:max_degradation_percent], page[:max_latency].to_f)

      AbCrunch::Logger.log :task, "Finding the max concurrency without degrading performance beyond a threshold"
      AbCrunch::Logger.log :info, "Threshold: #{threshold_ms} (ms)"
      AbCrunch::Logger.log :info, "Trying ever increasing concurrency until we bust the threshold"

      fmc_page = page.clone
      fmc_page[:concurrency] = 0
      abr = baseline_result
      begin
        fmc_page[:concurrency] += 1
        prev_result = abr
        abr = AbCrunch::BestRun.of_avg_response_time(fmc_page[:num_concurrency_runs], fmc_page)
      end while abr.avg_response_time < threshold_ms
      fmc_page[:concurrency] -= 1
      prev_result || baseline_result
    end

    def self.run(page)
      page = AbCrunch::Config.best_concurrency_options.merge(page)

      AbCrunch::Logger.log :strategy, "Strategy: find queries per second (QPS) at highest concurrency before latency degrades"

      AbCrunch::Logger.log :task, "Calculating Baseline (min average response time over multiple runs)"
      baseline_result = AbCrunch::BestRun.of_avg_response_time(page[:num_baseline_runs], page)

      best_result = find_best_concurrency(page, baseline_result)

      AbCrunch::Logger.log :progress, "Highest concurrency without degrading latency: #{best_result.ab_options[:concurrency]}"
      AbCrunch::Logger.log :result, "Queries Per Second (QPS): #{best_result.queries_per_second}"
      best_result.log

      best_result
    end
  end
end