require 'open3'
require 'pp'

module AbCrunch
  class AbRunner
    def self.validate_options(options)
      raise "AB Options missing :url" unless options.has_key? :url
      AbCrunch::Config.ab_options.merge(options)
    end

    def self.ab_command(options)
      options = validate_options(options)
      url = AbCrunch::Page.get_url(options, true)
      AbCrunch::Logger.log(:info, "Calling ab on:  #{url}")
      "ab -c #{options[:concurrency]} -n #{options[:num_requests]} -k -H 'Accept-Encoding: gzip' #{url}"
    end

    def self.ab(options)
      cmd = ab_command(options)
      result = nil

      Open3.popen3(cmd) do |stdin, stdout, stderr|
        err_lines = stderr.readlines
        if err_lines.length > 0
          cmd = cmd.cyan
          err = "AB command failed".red
          err_s = err_lines.reduce {|line, memo| memo += line}.red
          raise "#{err}\nCommand: #{cmd}\n#{err_s}"
        end
        result = AbCrunch::AbResult.new stdout.readlines.reduce {|line, memo| memo += line}, options
      end

      result
    end
  end
end