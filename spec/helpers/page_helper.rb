module RockHardAbsSpec

  FULL_TEST_PAGE = {
      :name => "some page",
      :url => "some url",
    }

  def self.new_page(override_options = {})
    FULL_TEST_PAGE.merge(override_options)
  end

  def self.new_result(page = FULL_TEST_PAGE)
    RockHardAbs::AbResult.new(FAKE_AB_RESULT_TEXT, page)
  end

  FAKE_AB_RESULT_TEXT = <<-ABRESULT
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.google.com (be patient).....done


Server Software:        gws
Server Hostname:        www.google.com
Server Port:            80

Document Path:          /
Document Length:        10372 bytes

Concurrency Level:      1
Time taken for tests:   0.880 seconds
Complete requests:      10
Failed requests:        0
   (Connect: 0, Receive: 0, Length: 8, Exceptions: 0)
Write errors:           0
Total transferred:      109542 bytes
HTML transferred:       103762 bytes
Requests per second:    11.36 [#/sec] (mean)
Time per request:       88.019 [ms] (mean)
Time per request:       88.019 [ms] (mean, across all concurrent requests)
Transfer rate:          121.54 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:       24   29   4.4     28      38
Processing:    56   59   3.2     59      66
Waiting:       52   55   3.4     55      64
Total:         80   88   6.4     88     103

Percentage of the requests served within a certain time (ms)
  50%     88
  66%     89
  75%     89
  80%     91
  90%    103
  95%    103
  98%    103
  99%    103
 100%    103 (longest request)
      ABRESULT
end