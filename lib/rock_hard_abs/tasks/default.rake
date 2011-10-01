namespace :rhs do
  task :require do
    
  end

  desc "Run default load tests"
  task :load_test => "rhs:require" do
    if RockHardAbs::Config.page_sets[:default]
      RockHardAbs::Tester.test(RockHardAbs::Config.page_sets[:default])
    else
      RockHardAbs::Logger.log(:failure, "nothing to do")
      message = "No default page set defined.  Please specify which page set to load test:"
      RockHardAbs::Config.page_sets.keys.each do |page_set_name|
        message += "\n  rake rhs:load_test:#{page_set_name}"
      end
      RockHardAbs::Logger.log(:info, message)
    end
  end
end