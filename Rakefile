require "bundler/gem_tasks"

Dir[File.join(File.dirname(__FILE__), "lib/**/*.rb")].each { |f| require f }
Dir[File.join(File.dirname(__FILE__), "lib/**/*.rake")].each  { |task| load(task) }

task :default do
  sh "rspec spec -fs"
end