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
    USPS.canned_verify_address_test.should == [{:Address2=>"6406 IVY LN", :City=>"GREENBELT", :State=>"MD", :Zip5=>"20770", :Zip4=>"1440"}, {:Address2=>"8 WILDWOOD DR", :City=>"OLD LYME", :State=>"CT", :Zip5=>"06371", :Zip4=>"1844"}]
  end

  it "Finds an address by zipcode" do
    USPS.canned_zip_lookup_test.should == [{:Address2=>"6406 IVY LN", :City=>"GREENBELT", :State=>"MD", :Zip5=>"20770", :Zip4=>"1440"}, {:Address2=>"8 WILDWOOD DR", :City=>"OLD LYME", :State=>"CT", :Zip5=>"06371", :Zip4=>"1844"}]
  end 

  it "Finds an address by city state" do
    USPS.canned_city_state_lookup_test.should == [{:Zip5=>"90210", :City=>"BEVERLY HILLS", :State=>"CA"}, {:Zip5=>"20770", :City=>"GREENBELT", :State=>"MD"}]
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
