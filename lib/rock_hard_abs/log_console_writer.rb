require 'colorize'

module RockHardAbs
  class LogConsoleWriter
    @@last_inline = false

    TYPE_STYLES = {
      :info => { :color => :white, :prefix => '  ' },
      :test => { :color => :light_white, :prefix => "\n\n-----" },
      :strategy => { :color => :light_white, :prefix => "\n" },
      :task => { :color => :white, :prefix => "\n " },
      :progress => { :color => :green, :prefix => '  ' },
      :result => { :color => :light_green, :prefix => '  ' },
      :ab_result => { :color => :cyan, :prefix => '    ' },
      :success => { :color => :light_green, :prefix => '  ' },
      :failure => { :color => :light_red, :prefix => '  ' },
      :summary => { :color => :light_white, :prefix => '' },
      :summary_passed => { :color => :light_green, :prefix => '' },
      :summary_failed => { :color => :light_red, :prefix => '' },

    }

    def self.color_for_type(type)
      TYPE_STYLES[type] ? TYPE_STYLES[type][:color] : :white
    end

    def self.prefix_for_type(type)
      TYPE_STYLES[type] ? TYPE_STYLES[type][:prefix] : ''
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