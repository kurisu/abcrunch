namespace :ac do
  desc "Run default load tests"
  task :load_test do
    if AbCrunch::Config.page_sets[:default]
      AbCrunch::Tester.test(AbCrunch::Config.page_sets[:default])
    else
      AbCrunch::Logger.log(:failure, "nothing to do")
      message = "No default page set defined.  Please specify which page set to load test:"
      AbCrunch::Config.page_sets.keys.each do |page_set_name|
        message += "\n  rake rhs:load_test:#{page_set_name}"
      end
      AbCrunch::Logger.log(:info, message)
    end
  end

  namespace :load_test do
    desc "Run load tests against ALL page sets"
    task :all do
      AbCrunch::Config.page_sets.keys.each do |page_set_key|
        AbCrunch::Tester.test(AbCrunch::Config.page_sets[page_set_key])
      end
    end
  end

end