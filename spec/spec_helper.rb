RSpec.configure do |conf|
  conf.mock_with :rr
end

Dir[File.join(File.dirname(__FILE__), "../lib/**/*.rb")].each { |f| require f }

Dir[File.join(File.dirname(__FILE__), "helpers/**/*.rb")].each { |f| require f }
