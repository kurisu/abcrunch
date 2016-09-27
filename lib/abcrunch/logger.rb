require File.join(File.dirname(__FILE__), 'log_console_writer')

module AbCrunch
  module Logger
    class << self
      attr_accessor :writers
    end

    @writers = [AbCrunch::LogConsoleWriter]

    def self.log(type, message, options = {})
      writers.each { |writer| writer.log(type, message, options) }
    end
  end
end