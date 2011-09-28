test_pages = [
  {:name => 'Price Drop Widget', :url => 'http://widgets.qa.honk.com/wsj/price-drop?pag_id=179'},
  {:name => 'Histogram Widget', :url => 'http://widgets.qa.honk.com/wsj/histogram?pag_id=179&make=toyota&model=corolla&year=2010&body_type=sedan'},
  {:name => 'ES Hybrids Widget', :url => 'http://widgets.qa.honk.com/wsj/search?preset=hybrids&zip=95101'},
  {:name => 'Makes list page', :url => 'https://staging.honk.com/wsj/makes'},
  {:name => 'Landing Page', :url => 'https://staging.honk.com/wsj/new-cars'},
  {:name => 'Trends Page', :url => 'https://staging.honk.com/wsj/new-car-trends'},
  {:name => 'Explore Search Tool', :url => 'https://staging.honk.com/wsj/explore'},
  {:name => 'Make Landing Page', :url => 'https://staging.honk.com/wsj/toyota'},
  {:name => 'Model Landing Page', :url => 'https://staging.honk.com/wsj/toyota/corolla/sedan/2010/4dr-sedan-man'},
  {:name => 'Model Reviews Page', :url => 'https://staging.honk.com/wsj/toyota/corolla/sedan/2010/4dr-sedan-man/reviews'},
  {:name => 'Model Price Page', :url => 'https://staging.honk.com/wsj/toyota/corolla/sedan/2010/4dr-sedan-man/price'},
  {:name => 'Model Specs Page', :url => 'https://staging.honk.com/wsj/toyota/corolla/sedan/2010/4dr-sedan-man/tech_specs'},
  {:name => 'Model Photos Page', :url => 'https://staging.honk.com/wsj/toyota/corolla/sedan/2010/4dr-sedan-man/media'}
]

def parse_ab_data(ab_log)
  {
    :response_time => ab_log.match(/Time per request:\s*([\d\.]+)\s\[ms\]\s\(mean\)/)[1].to_f,
    :queries_per_second => ab_log.match(/Requests per second:\s*([\d\.]+)\s\[#\/sec\]\s\(mean\)/)[1].to_f,
    :failed_requests => ab_log.match(/Failed requests:\s*([\d\.]+)/)[1].to_f
  }
end

def ab(url, concurrency, num_requests)
  `ab -c #{concurrency} -n #{num_requests} #{url}`
end

def best_of(url, concurrency, num_requests, num_runs)
  min_response_time = 999999
  min_response_log = ''
  puts "\nBest of #{num_runs} at concurrency: #{concurrency} and num_requests: #{num_requests}"
  puts "Collecting average response times for each run:"
  num_runs.times do
    ab_log = ab(url, concurrency, num_requests)
    response_time = parse_ab_data(ab_log)[:response_time]
    print "#{response_time} ... "
    STDOUT.flush
    if response_time < min_response_time
      min_response_time = response_time
      min_response_log = ab_log
    end
  end
  [min_response_time, min_response_log]
end

def baseline_page(page)
  puts "\nCalculating Baseline (min average response time over multiple runs)"
  best_of(page[:url], 1, 10, 5)
end

def find_max_concurrency(page, baseline_response_time, baseline_log, threshold_percent)
  puts "\nFinding the max concurrency without degrading performance beyond a threshold"
  threshold_ms = [1000.0, baseline_response_time * (1 + threshold_percent)].min
  puts "Threshold: #{threshold_ms} (ms)"
  print "Trying ever increasing concurrency until we bust the threshold"
  concurrency = 0
  ab_log = baseline_log
  begin
    concurrency += 1
    prev_log = ab_log
    response_time, ab_log = best_of(page[:url], concurrency, 10, 3)
  end while response_time < threshold_ms
  [concurrency - 1, threshold_ms, prev_log]
end

test_pages.each do |page|
  puts "\n\n\n=========== Testing #{page[:name]}..."

  baseline_response_time, baseline_output = baseline_page(page)
  page[:baseline_response_time] = baseline_response_time
  puts "\n----- Min Average Response Time was #{baseline_response_time}"
  #puts "----- Matching AB Output"
  #puts baseline_output

  max_concurrency, threshold, mc_output = find_max_concurrency(page, baseline_response_time, baseline_output, 0.5)
  page[:max_concurrency] = max_concurrency
  page[:threshold] = threshold
  page[:queries_per_second] = parse_ab_data(mc_output)[:queries_per_second]
  puts "\n----- Max Concurrency was #{max_concurrency}"
  puts "----- Threshold was #{threshold}"
  puts "----- Matching AB Output at max concurrency"
  puts mc_output
end

class Float
  alias_method :orig_to_s, :to_s
  def to_s(arg = nil)
    if arg.nil?
      orig_to_s
    else
      sprintf("%.#{arg}f", self)
    end
  end
end

puts "\nSummary"
puts "#{"Page".ljust(30, ' ')}#{"Baseline".rjust(10, ' ')}  #{"Max Concurrency".rjust(16, ' ')}  #{"Threshold".rjust(10, ' ')}  #{"Queries/sec".rjust(12, ' ')}"
test_pages.each do |page|
  puts "#{page[:name].ljust(30, ' ')}#{page[:baseline_response_time].to_s(2).rjust(10, ' ')}  #{page[:max_concurrency].to_s.rjust(16, ' ')}  #{page[:threshold].to_s(0).rjust(10, ' ')}  #{page[:queries_per_second].to_s(2).rjust(12, ' ')}"
end
puts "\nBaseline = Best average response time (ms) over multiple runs with no concurrency"
puts "Max Concurrency = Most concurrent requests where best average response time doesn't bust our performance threshold"
puts "Queries/sec = Queries per second at max concurrency"