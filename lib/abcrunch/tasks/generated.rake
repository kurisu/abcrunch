namespace :abcrunch do

  AbCrunch::Config.page_sets.keys.each do |page_set_key|
    unless Rake::Task.task_defined? page_set_key
      desc "Run load tests for #{page_set_key}"
      task page_set_key do
        AbCrunch::Tester.test(AbCrunch::Config.page_sets[page_set_key])
      end

      namespace page_set_key do
        desc "Run a focused page load test in #{page_set_key}. Example rake abcrunch:#{page_set_key}:focus[0] runs the first page"
        task :focus, [:page_index] do |t, args|
          unless verify_abcrunch_args(args, page_set_key)
            raise "usage: rake abcrunch:#{page_set_key}:focus[<page_index>]"
          end

          orig_page = AbCrunch::Config.page_sets[page_set_key][args[:page_index].to_i]
          AbCrunch::PageTester.test(orig_page)
        end

        def verify_abcrunch_args(args, page_set_key)
          max_idx = AbCrunch::Config.page_sets[page_set_key].length-1
          if !args[:page_index]
            puts "Focusing on... NOTHING!  (dork)"
            return false
          elsif !(0..max_idx).include?(args[:page_index].to_i)
            puts "Page index (#{args[:page_index]}) not in range (0..#{max_idx})"
            return false
          end
          true
        end
      end
    end
  end

end