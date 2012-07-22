require 'spec_helper'

USPS_USERNAME = '782G50004335'

describe AwesomeUsps do

  it "can be instantiated" do
    AwesomeUsps::USPS.new(USPS_USERNAME).should_not be_nil
  end

end