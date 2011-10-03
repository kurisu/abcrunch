require 'spec_helper'

describe "AbCrunch::Page" do
  describe "#get_url" do
    describe "when the page url is a string" do
      it "should return the string" do
        page = { :url => 'some url' }

        AbCrunch::Page.get_url(page).should == 'some url'
      end
    end

    describe "when the page url is a proc" do
      it "should call the proc and return the result" do
        page = { :url => Proc.new { 'a proc url' } }

        AbCrunch::Page.get_url(page).should == 'a proc url'
      end

      describe "when the page url is a proc returning different results each call" do

        before :each do
          @call_num = 0
          @page = { :url => Proc.new { @call_num += 1 ; "changing url #{@call_num}" } }
        end

        describe "when called repeatedly without force_new" do
          it "should return the same url each time" do
            AbCrunch::Page.get_url(@page).should == 'changing url 1'
            AbCrunch::Page.get_url(@page).should == 'changing url 1'
            AbCrunch::Page.get_url(@page).should == 'changing url 1'
          end
        end

        describe "when called repeadedly with force_new = True" do
          it "should return different urls each time" do
            AbCrunch::Page.get_url(@page, true).should == 'changing url 1'
            AbCrunch::Page.get_url(@page, true).should == 'changing url 2'
            AbCrunch::Page.get_url(@page, true).should == 'changing url 3'
          end
        end
      end
    end

  end
end