require 'colorize'

module RockHardAbs
  class AbConsoleWriter
    @@last_inline = false

    def self.color_for_type(type)
      {
        :info => :white,
        :success => :light_green,
        :ab_result => :cyan,
        :task => :light_white,
      }[type]
    end

    def self.prefix_for_type(type)
      {
        :info => '  ',
        :success => '  ',
        :ab_result => '    ',
        :task => "\n",
      }[type]
    end

    def self.log(type, message, options = {})
      a_message = prefix_for_type(type) + message
      if options[:inline]
        print a_message.send(color_for_type type)
        @@last_inline = true
      else
        a_message = "\n#{a_message}" if @@last_inline
        puts a_message.send(color_for_type type)
        @@last_inline = false
      end
    end
  end
end