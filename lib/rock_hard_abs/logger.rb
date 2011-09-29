module RockHardAbs
  module Logger
    class << self
      attr_accessor :writers
    end

    @writers = [RockHardAbs::AbConsoleWriter]

    def self.log(type, message, options = {})
      writers.each { |writer| writer.log(type, message, options) }
    end
  end
end