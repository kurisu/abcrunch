namespace :ac do
  namespace :load_test do

    AbCrunch::Config.page_sets.keys.each do |page_set_key|
      if page_set_key != :default
        desc "Run load tests for #{page_set_key}"
        task page_set_key do
          AbCrunch::Tester.test(AbCrunch::Config.page_sets[page_set_key])
        end
      end
    end

  end
end