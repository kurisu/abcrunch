require 'spec_helper'

describe "AbCrunch::AbResult" do
  def new_abr(raw_ab_output, ab_options = {})
    AbCrunch::AbResult.new(raw_ab_output, ab_options)
  end

  describe "#initialize" do
    it "should remember the provided raw ab output and options" do
      abr = new_abr('foo', {:foo => 'bar'})
      abr.raw.should == 'foo'
      abr.ab_options.should == {:foo => 'bar'}
    end
  end

  describe "#command" do
    it "should return the ab command used to produce the result" do
      ab_options = {:crunch => 'now'}
      mock(AbCrunch::AbRunner).ab_command(ab_options) { 'tight!' }
      abr = new_abr('blah', ab_options)
      abr.command.should == 'tight!'
    end
  end

  describe "#avg_response_time" do
    it "should glean the average response time from raw ab output and return as a float" do
      abr = new_abr("fleeblesnork\nTime per request:       43.028 [ms] (mean)\n\nblah")
      abr.avg_response_time.should == 43.028
    end

    describe "when the raw value is an integer" do
      it "should still be returned as a float" do
        abr = new_abr("fleeblesnork\nTime per request:       43 [ms] (mean)\n\nblah")
        abr.avg_response_time.should == 43.0
        abr.avg_response_time.class.to_s.should == 'Float'
      end
    end
  end

  describe "#queries_per_second" do
    it "should glean the queries per second from raw ab output and return as a float" do
      abr = new_abr("fleeblesnork\nRequests per second:    162.68 [#/sec] (mean)\n\nblah")
      abr.queries_per_second.should == 162.68
    end

    describe "when the raw value is an integer" do
      it "should still be returned as a float" do
        abr = new_abr("fleeblesnork\nRequests per second:    162 [#/sec] (mean)\n\nblah")
        abr.queries_per_second.should == 162.0
        abr.queries_per_second.class.to_s.should == 'Float'
      end
    end
  end

  describe "#failed_requests" do
    it "should glean the failed request count from raw ab output and return as a fixnum" do
      abr = new_abr("fleeblesnork\nFailed requests:        17\n\nblah")
      abr.failed_requests.should == 17
      abr.failed_requests.class.to_s.should == 'Fixnum'
    end
  end

  describe "#log" do
    it "should log command, avg response time,  queries per second, and failed requests" do
      ab_options = {:crunch => 'now'}
      abr = new_abr('blah', ab_options)
      mock(abr).command { 'tight!' }
      mock(abr).avg_response_time { "186" }
      mock(abr).queries_per_second { "50" }
      mock(abr).failed_requests { '10' }
      #  ...
      lines = []
      stub(AbCrunch::Logger).log { |*args|
        args[0].should == :ab_result
        lines << args[1]
      }
      abr.log
      lines.should == [
        'tight!',
        'Average Response Time: 186',
        'Queries per Second: 50',
        'Failed requests: 10'
      ]
    end
  end

end