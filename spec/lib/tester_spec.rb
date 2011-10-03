require 'spec_helper'

describe "AbCrunch::Tester" do
  before :each do
    stub(AbCrunch::Logger).log

    @test_pages = [
      AbCrunchSpec.new_page,
      AbCrunchSpec.new_page,
      AbCrunchSpec.new_page,
    ]

    @fake_page_results = [
      [true, AbCrunchSpec.new_result, []],
      [true, AbCrunchSpec.new_result, []],
      [true, AbCrunchSpec.new_result, []],
    ]

    @fake_failed_page_results = [
      [true, AbCrunchSpec.new_result, []],
      [true, AbCrunchSpec.new_result, []],
      [false, AbCrunchSpec.new_result, ['some error','another']],
    ]
  end

  describe "#test" do
    it "should test each of the given pages" do
      tested_pages = []

      stub(AbCrunch::PageTester).test do |page|
        tested_pages << page
        @fake_page_results[0]
      end

      AbCrunch::Tester.test(@test_pages)

      tested_pages.should == @test_pages
    end

    it "should collect and return the results for every page" do
      expected_test_results = @fake_page_results.each_with_index.map do |page_result, idx|
        {
          :page => @test_pages[idx],
          :passed => page_result[0],
          :qps_result => page_result[1],
          :errors => page_result[2]
        }
      end

      call_idx = -1
      stub(AbCrunch::PageTester).test do
        call_idx += 1
        @fake_page_results[call_idx]
      end

      test_results = AbCrunch::Tester.test(@test_pages)

      test_results.should == expected_test_results
    end

    it "should raise an error if there are any load test failures" do
      call_idx = -1
      stub(AbCrunch::PageTester).test do
        call_idx += 1
        @fake_failed_page_results[call_idx]
      end

      lambda do
        AbCrunch::Tester.test(@test_pages)
      end.should raise_error "Load tests FAILED\nsome error\nanother"
    end
  end
end