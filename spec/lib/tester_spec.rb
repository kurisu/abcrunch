require 'spec_helper'

describe "RockHardAbs::Tester" do
  before :each do
    stub(RockHardAbs::Logger).log

    @test_pages = [
      RockHardAbsSpec.new_page,
      RockHardAbsSpec.new_page,
      RockHardAbsSpec.new_page,
    ]

    @fake_page_results = [
      [true, RockHardAbsSpec.new_result, []],
      [true, RockHardAbsSpec.new_result, []],
      [false, RockHardAbsSpec.new_result, ['some error','another']],
    ]
  end

  describe "#test" do
    it "should test each of the given pages" do
      tested_pages = []

      stub(RockHardAbs::PageTester).test do |page|
        tested_pages << page
        @fake_page_results[0]
      end

      RockHardAbs::Tester.test(@test_pages)

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
      stub(RockHardAbs::PageTester).test do
        call_idx += 1
        @fake_page_results[call_idx]
      end

      test_results = RockHardAbs::Tester.test(@test_pages)

      test_results.should == expected_test_results
    end
  end
end