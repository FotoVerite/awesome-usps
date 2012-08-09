module AwesomeUsps
  module CannedTests

    PACKAGES= [
        Package.new(  100,
        [93,10],
        :cylinder => true),

        Package.new(  (7.5 * 16),
        [15, 10, 4.5],
        :units => :imperial)
      ]

    US_ORIGIN = Location.new( :name=> "John Smith",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')

    DOMESTIC_LOCATIONS = [US_ORIGIN, Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371"   )]

    US_DESTINATION = Location.new( :name=> "Joe Customer",  :address2 =>"136 Linwood Plz",  :state => 'NJ', :city => 'Fort Lee', :zip5 => "07024")

    RETAILER =Location.new( :name=> "XYZ Corp.",  :address2 =>"1100 West Avenue")

    PDU =  Location.new(  :state => 'PA', :city => 'Wilkes Barre', :address2 =>"PO Box 100", :zip5 => "18702" )


    def canned_domestic_rates_test
      origin_zip = "07024"
      destination_zip = "10010"
      options = {}
      request = xml_for_us(origin_zip, destination_zip, PACKAGES, options)
      gateway_commit(:us_rates, 'RateV3', request, :live)
    end


    def canned_world_rates_test
      country = "Japan"
      options ={}
      request = xml_for_world(country, PACKAGES, options)
      gateway_commit(:world_rates,'IntlRate', request, :live)
    end

    def canned_verify_address_test
      request = xml_for_address_information_api("AddressValidateRequest", DOMESTIC_LOCATIONS)
      gateway_commit(:verify_address, 'Verify', request, :test)
    end

    def canned_zip_lookup_test
      request = xml_for_address_information_api("ZipCodeLookupRequest", DOMESTIC_LOCATIONS)
      gateway_commit(:zip_lookup, 'ZipCodeLookup', request, :test)
    end

    def canned_city_state_lookup_test
      request = xml_for_address_information_api("CityStateLookupRequest", [Location.new(:zip5 => 90210), Location.new(:zip5 => 20770)])
      gateway_commit(:zip_lookup, 'CityStateLookup', request, :test)
    end


    def canned_delivery_confirmation_label_test
      service_type = "Priority"
      image_type ="PDF"
      label_type = 1
      options = {:weight => 2}
      api_request = "DelivConfirmCertifyV3.0Request"
      request = confirmation_xml(api_request, US_ORIGIN, US_DESTINATION, service_type, image_type, label_type, options)
      gateway_commit(:delivery_confirmation_certify,'DelivConfirmCertifyV3', request, :ssl, image_type)
    end

    def canned_signature_confirmation_label_test
      service_type = "Priority"
      image_type ="PDF"
      label_type = 1
      options = {:weight => 2}
      api_request = "SigConfirmCertifyV3.0Request"
      request = confirmation_xml(api_request, US_ORIGIN, US_DESTINATION, service_type, image_type, label_type, options)
      gateway_commit(:signature_confirmation_certify, 'SignatureConfirmationCertifyV3', request, :ssl, image_type)
    end

    def canned_merch_return_test
      service_type ="Priority"
      permit_number = "293829"
      post_office = Location.new(  :state => 'NY', :city => 'New York', :zip5 => '10018')
      ounces = "52"
      options = {:RMA => "13456", :insurance => "500", :confirmation => "true"}
      image_type ="PDF"
      api_request = "EMRSV4.0Request"
      request = merch_return_xml(api_request, "LEFTWINDOW", service_type, US_ORIGIN, RETAILER, permit_number, post_office, PDU,  ounces, image_type, options)
      gateway_commit(:merchandise_return_certify, 'MerchandiseReturnV4', request, :ssl, image_type)
    end

  end 


end