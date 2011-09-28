module RockHardAbs
  class AbRunner
    def self.ab_command(options)
      "ab -c #{options[:concurrency]} -n #{options[:num_requests]} #{options[:url]}"
    end

    def self.ab(options)
      RockHardAbs::AbResult.new `#{ab_command(options)}`, options
    end
  end
end