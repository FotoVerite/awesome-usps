require 'spec_helper'

describe AwesomeUsps do

  it "settings.rb exists" do
    File.exist?('spec/settings.rb').should be_true
  end

  it "can be instantiated" do
    AwesomeUsps::USPS.new(USPS_USERNAME).should_not be_nil
  end

end