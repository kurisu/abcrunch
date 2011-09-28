module RockHardAbs
  class AbRunner
    def self.ab(options)
      RockHardAbs::AbResult.new `ab -c #{options[:concurrency]} -n #{options[:num_requests]} #{options[:url]}`
    end
  end
end