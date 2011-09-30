module RockHardAbs
  module Config
    class << self
      attr_accessor :best_concurrency_options, :ab_options
    end

    @best_concurrency_options = {
      :max_degradation_percent => 0.5,
      :max_latency => 1000.0,
      :num_baseline_runs => 5,
      :num_concurrency_runs => 3
    }

    @ab_options = {
      :concurrency => 1,
      :num_requests => 10
    }
  end
end