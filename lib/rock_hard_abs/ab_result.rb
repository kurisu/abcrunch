module RockHardAbs
  class AbResult
    attr_accessor :raw

    def initialize(raw_ab_output)
      @raw = raw_ab_output
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
  end
end