module RockHardAbs
  class AbRunner
    def self.validate_options(options)
      raise "AB Options missing :url" unless options.has_key? :url
      RockHardAbs::Config.ab_options.merge(options)
    end

    def self.ab_command(options)
      options = validate_options(options)
      "ab -c #{options[:concurrency]} -n #{options[:num_requests]} #{options[:url]}"
    end

    def self.ab(options)
      RockHardAbs::AbResult.new `#{ab_command(options)}`, options
    end
  end
end