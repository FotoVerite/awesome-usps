require 'spec_helper'

describe AwesomeUsps do

  before(:all) do
   USPS = AwesomeUsps::USPS.new(USPS_USERNAME)
  end

  it "Find all domestic rates for two packages" do
    USPS.canned_domestic_rates_test.size.should == 2
  end

  it "Find all international rates for two packages" do
    USPS.canned_world_rates_test.size.should == 2
  end

  it "Verify that an address is accurate" do
    USPS.canned_verify_address_test.should == [{:address2=>"6406 IVY LN", :city=>"GREENBELT", :state=>"MD", :zip5=>"20770", :zip4=>"1440"}, {:address2=>"8 WILDWOOD DR", :city=>"OLD LYME", :state=>"CT", :zip5=>"06371", :zip4=>"1844"}]
  end

  it "Finds an address by zipcode" do
    USPS.canned_zip_lookup_test.should == [{:address2=>"6406 IVY LN", :city=>"GREENBELT", :state=>"MD", :zip5=>"20770", :zip4=>"1440"}, {:address2=>"8 WILDWOOD DR", :city=>"OLD LYME", :state=>"CT", :zip5=>"06371", :zip4=>"1844"}]
  end 

  it "Finds an address by city state" do
    USPS.canned_city_state_lookup_test.should == [{:zip5=>"90210", :city=>"BEVERLY HILLS", :state=>"CA"}, {:zip5=>"20770", :city=>"GREENBELT", :state=>"MD"}]
  end 

  it "should return a delivery label" do
    result = USPS.canned_delivery_confirmation_label_test
    result[:image_type].should == "application/pdf"
    result[:label].should_not be_nil
  end

  it "should return a signature label" do
    result = USPS.canned_signature_confirmation_label_test
    result[:image_type].should == "application/pdf"
    result[:label].should_not be_nil
  end

  it "should return a merch label" do
    result = USPS.canned_merch_return_test
    result[:image_type].should == "application/pdf"
    result[:label].should_not be_nil
  end

end
