require 'spec_helper'

module AwesomeUsps
  describe Location do

    before(:all) do
     @location = Location.new( :name=> "John Smith",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
    end

    it "#to_s returns a properly formatted string" do
      expect(@location.to_s).to eq("John Smith, 6406 Ivy Lane, Greenbelt, MD, 20770")
    end

    it "postal_code is an alias method to zip5" do
      expect(@location.postal_code).to eq(@location.zip5)
    end

    it "postal is an aliase method to postal_code" do
      expect(@location.postal).to eq(@location.postal_code)
    end

    it "zip is an alias method of postal" do
      expect(@location.zip).to eq(@location.postal)
    end

    it "province is an alias method of state" do
      expect(@location.province).to eq(@location.state)
    end

    it "territory is an alias method of province" do
      expect(@location.territory).to eq(@location.province)
    end

    it "region is an alias method of province" do
      expect(@location.region).to eq(@location.province)
    end

    it "first_name is an alias method of name" do
      expect(@location.first_name).to eq(@location.name)
    end

    it "" do

    end

  end
end