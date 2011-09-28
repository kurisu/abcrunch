require 'spec_helper'

describe "RockHardAbs::AbResult" do
  def new_abr(raw_ab_output)
    RockHardAbs::AbResult.new(raw_ab_output)
  end

  describe "#initialize" do
    it "should remember the provided raw ab output" do
      abr = new_abr('foo')
      abr.raw.should == 'foo'
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

end