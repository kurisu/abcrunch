module RockHardAbs
  module PageTester
    def self.test(page)
      RockHardAbs::Logger.log :test, "Testing #{page[:name]}"
      RockHardAbs::Logger.log :info, "#{page[:url]}"

      max_con_options = RockHardAbs::Config.max_con_options

      if page[:max_avg_response_time]
        max_con_options.merge!({:max_latency => page[:max_avg_response_time]})
      end
      qps_result = RockHardAbs::StrategyQpsAtBestConcurrency.run(page[:url], max_con_options, RockHardAbs::Config.ab_options)

      passed = true
      errors = []

      if page[:max_avg_response_time]
        if qps_result.avg_response_time > page[:max_avg_response_time]
          passed = false
          errors << "Avg response time of #{qps_result.avg_response_time} must be <= #{page[:max_avg_response_time]}"
        end
      end

      if page[:min_queries_per_second]
        if qps_result.queries_per_second < page[:min_queries_per_second]
          passed = false
          errors << "QPS of #{qps_result.queries_per_second} must be >= #{page[:min_queries_per_second]}"
        end
      end

      if qps_result.failed_requests > 0
        passed = false
        errors << "Load test invalidated: #{qps_result.failed_requests} requests failed"
      end

      if passed
        RockHardAbs::Logger.log :success, "PASSED"
      else
        errors.each { |error| RockHardAbs::Logger.log :failure, error }
        RockHardAbs::Logger.log :failure, "#{page[:name]} FAILED"
      end

      [passed, qps_result]
    end
  end
end