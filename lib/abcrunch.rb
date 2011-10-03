require "abcrunch/version"

Dir[File.join(File.dirname(__FILE__), "lib/**/*.rb")].each { |f| require f }

Dir[File.join(File.dirname(__FILE__), "lib/**/*.rake")].
  concat(Dir[File.join(File.dirname(__FILE__), "tasks/**/*.rake")]).each  { |rake| load(rake) }

module AbCrunch
  def self.root
    File.dirname(File.dirname(__FILE__))
  end
end
