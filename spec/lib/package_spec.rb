require 'spec_helper'

module AwesomeUsps
  describe Package do
    before(:all) do
      @imperial_package = Package.new(32, [5, 5, 5], { :units => :imperial, :value => 5.50 })
      @metric_package = Package.new(907, [5,5,5], { :units => :metric })
    end

    context "conversions to ounces and pounds" do

      it "should correctly calculate volumetric ounces from metric" do
        expect(@metric_package.ounces({:type => :volumetric})).to eq(0.7)
      end

      it "should correctly calculate volumetric ounces from imperial" do
        expect(@imperial_package.ounces({:type => :volumetric})).to eq(12.0)
      end

      it "should correctly convert grams to ounces" do
        expect(@metric_package.ounces({:type => :actual})).to eq(32)
      end

      it "should correctly convert grams to pounds" do
        expect(@metric_package.pounds).to eq(2)
      end

    end

    context "conversions to grams and kilograms" do

      # volumetric grams makes no sense to me at all
      # these tests are placeholders to allow safe refactoring
      it "should output something regarding volumetric grams" do
        expect(@imperial_package.grams({:type => :volumetric})).to eq(341)
      end

      it "should correctly convert ounces to grams" do
        expect(@imperial_package.grams({:type => :actual})).to eq(907.185)
      end

      it "should correctly convert ounces to kilograms" do
        expect(@imperial_package.kilograms).to eq(0.907)
      end

    end

    context "conversions to inches and centimetres" do

      it "should correctly convert inches to centimetres" do
        expect(@imperial_package.centimetres).to eq([12.7, 12.7, 12.7])
      end

      it "should correctly convert centimetres to inches" do
        expect(@metric_package.inches).to eq([2.0, 2.0, 2.0])
      end

    end

    it "should convert dollars to cents" do
      expect(Package.cents_from(5.50)).to eq(550)
      expect(@imperial_package.value).to eq(550)
    end

  end
end