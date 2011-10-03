module AbCrunch
  class AbResult
    attr_accessor :raw, :ab_options

    def initialize(raw_ab_output, ab_options)
      @raw = raw_ab_output
      @ab_options = ab_options
    end

    def command
      AbCrunch::AbRunner.ab_command(@ab_options)
    end

    def avg_response_time
      raw.match(/Time per request:\s*([\d\.]+)\s\[ms\]\s\(mean\)/)[1].to_f
    end

    def queries_per_second
      raw.match(/Requests per second:\s*([\d\.]+)\s\[#\/sec\]\s\(mean\)/)[1].to_f
    end

    def failed_requests
      raw.match(/Failed requests:\s*([\d\.]+)/)[1].to_i
    end

    def log
      AbCrunch::Logger.log :ab_result, "#{command}"
      AbCrunch::Logger.log :ab_result, "Average Response Time: #{avg_response_time}"
      AbCrunch::Logger.log :ab_result, "Queries per Second: #{queries_per_second}"
      AbCrunch::Logger.log :ab_result, "Failed requests: #{failed_requests}"
    end
  end
end