module RockHardAbs
  module Tester
    def self.test(pages)
      results = []

      pages.each do |page|
        passed, qps_result, errors = RockHardAbs::PageTester.test(page)
        results << {
          :page => page,
          :passed => passed,
          :qps_result => qps_result,
          :errors => errors
        }
      end

      log_result_summary results

      passed = results.reduce(true) { |value, result| value && result[:passed] }

      if not passed
        errors = results.reduce('') do |value, result|
          page_set_errors = result[:errors].reduce('') do |val, error|
            "#{val}#{val.length > 0 ? "\n" : ''}#{error}"
          end
          "#{value}#{value.length > 0 ? "\n" : ''}#{page_set_errors}"
        end

        raise "Load tests FAILED\n#{errors}"
      end

      results
    end

    def self.log_result_summary(results)
      RockHardAbs::Logger.log :summary_title, "Summary"
      RockHardAbs::Logger.log :summary, "#{"Page".ljust(30, ' ')}#{"Response time".rjust(10, ' ')}  #{"Concurrency".rjust(16, ' ')}  #{"Queries/sec".rjust(12, ' ')}"
      results.each do |result|
        page_name = result[:page][:name].ljust(30, ' ')
        base_response_time = sprintf("%.2f", result[:qps_result].avg_response_time).rjust(10, ' ')
        max_concurrency = result[:qps_result].ab_options[:concurrency].to_s.rjust(16, ' ')
        queries_per_second = sprintf("%.2f", result[:qps_result].queries_per_second).rjust(12, ' ')
        if result[:passed]
          RockHardAbs::Logger.log :summary_passed, "#{page_name}#{base_response_time}  #{max_concurrency}  #{queries_per_second}"
        else
          RockHardAbs::Logger.log :summary_failed, "#{page_name}#{base_response_time}  #{max_concurrency}  #{queries_per_second}"
        end
      end
      RockHardAbs::Logger.log :summary_title, "Legend"
      RockHardAbs::Logger.log :summary, "Response Time = Best average response time (ms) at max concurrency"
      RockHardAbs::Logger.log :summary, "Concurrency = Best concurrency where response time doesn't bust our performance threshold"
      RockHardAbs::Logger.log :summary, "Queries/sec = Queries per second at best concurrency"

      results
    end
  end
end