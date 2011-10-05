RSpec.configure do |conf|
  conf.mock_with :rr
end

require File.join(File.dirname(__FILE__), "../lib/abcrunch")

Dir[File.join(File.dirname(__FILE__), "helpers/**/*.rb")].each { |f| require f }