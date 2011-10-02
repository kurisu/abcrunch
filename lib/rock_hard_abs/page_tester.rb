module RockHardAbs
  module PageTester
    def self.test(page)
      RockHardAbs::Logger.log :test, "Testing #{page[:name]}"
      RockHardAbs::Logger.log :info, "#{page[:url]}"

      if page[:max_avg_response_time]
        page.merge!({:max_latency => page[:max_avg_response_time]})
      end
      qps_result = RockHardAbs::StrategyBestConcurrency.run(page)

      passed = true
      errors = []

      if page[:max_avg_response_time]
        if qps_result.avg_response_time > page[:max_avg_response_time]
          passed = false
          errors << "#{page[:name]}: Avg response time of #{qps_result.avg_response_time} must be <= #{page[:max_avg_response_time]}"
        end
      end

      if page[:min_queries_per_second]
        if qps_result.queries_per_second < page[:min_queries_per_second]
          passed = false
          errors << "#{page[:name]}: QPS of #{qps_result.queries_per_second} must be >= #{page[:min_queries_per_second]}"
        end
      end

      if qps_result.failed_requests > 0
        passed = false
        errors << "#{page[:name]}: Load test invalidated: #{qps_result.failed_requests} requests failed"
      end

      if passed
        RockHardAbs::Logger.log :success, "PASSED"
      else
        errors.each { |error| RockHardAbs::Logger.log :failure, error }
        RockHardAbs::Logger.log :failure, "#{page[:name]} FAILED"
      end

      [passed, qps_result, errors]
    end
  end
end