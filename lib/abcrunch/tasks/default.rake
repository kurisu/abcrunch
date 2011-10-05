namespace :abcrunch do
  desc "Run load tests against ALL page sets"
  task :all do
    if AbCrunch::Config.page_sets.length == 0
      AbCrunch::Logger.log(:failure, "No page sets defined. Nothing to do")
    end

    AbCrunch::Config.page_sets.keys.each do |page_set_key|
      AbCrunch::Tester.test(AbCrunch::Config.page_sets[page_set_key])
    end
  end
end