module RockHardAbs
  class StrategyQpsAtBestConcurrency

    DEFAULT_AB_OPTIONS = {
      :concurrency => 1,
      :num_requests => 10
    }

    DEFAULT_MAX_CON_OPTIONS = {
      :max_degradation_percent => 0.5,
      :max_latency => 1000.0,
      :num_baseline_runs => 5,
      :num_concurrency_runs => 3
    }

    def self.baseline_page(num_runs, ab_options)
      RockHardAbs::Logger.log :task, "Calculating Baseline (min average response time over multiple runs)"
      RockHardAbs::BestRun.of_avg_response_time(num_runs, ab_options)
    end

    def self.find_max_concurrency(ab_options, base_result, options)
      RockHardAbs::Logger.log :task, "Finding the max concurrency without degrading performance beyond a threshold"
      threshold_ms = [options[:max_latency].to_f, base_result.avg_response_time * (1 + options[:max_degradation_percent])].min

      RockHardAbs::Logger.log :info, "Threshold: #{threshold_ms} (ms)"
      RockHardAbs::Logger.log :info, "Trying ever increasing concurrency until we bust the threshold"
      ab_options[:concurrency] = 0
      abr = base_result
      begin
        ab_options[:concurrency] += 1
        prev_result = abr
        abr = RockHardAbs::BestRun.of_avg_response_time(options[:num_concurrency_runs], ab_options)
      end while abr.avg_response_time < threshold_ms
      prev_result || base_result
    end

    def self.run(url, max_con_options = {}, ab_options = {})
      max_con_options = max_con_options || {}
      max_con_options = DEFAULT_MAX_CON_OPTIONS.merge(max_con_options)
      ab_options = ab_options || {}
      ab_options = DEFAULT_AB_OPTIONS.merge(ab_options)
      ab_options.merge!({:url => url})

      RockHardAbs::Logger.log :strategy, "Strategy: find queries per second (QPS) at highest concurrency before latency degrades"
      base_result = baseline_page(max_con_options[:num_baseline_runs], ab_options)
      best_result = find_max_concurrency(ab_options, base_result, max_con_options)

      RockHardAbs::Logger.log :progress, "Highest concurrency without degrading latency: #{best_result.ab_options[:concurrency]}"
      RockHardAbs::Logger.log :result, "Queries Per Second (QPS): #{best_result.queries_per_second}"
      best_result.log
      best_result
    end
  end
end