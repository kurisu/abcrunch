module RockHardAbs
  module Config
    class << self
      attr_accessor :max_con_options, :ab_options
    end

    @max_con_options = {}
    @ab_options = {}
  end
end