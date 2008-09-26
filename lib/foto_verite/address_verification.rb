module FotoVerite
  module AddressVerification
    MAX_RETRIES = 3

    LIVE_DOMAIN = 'production.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    TEST_DOMAIN ='testing.shippingapis.com'
    TEST_RESOURCE = '/ShippingAPITest.dll'

    API_CODES ={
      :verify_address => 'Verify',
      :zip_lookup => 'ZipCodeLookup',
    :city_state_lookup =>"CityStateLookup"}

    # Examines address and fills in missing information. Address must include city & state or the zip to be processed.
    # Can do up to an array of five
    def veryify_address(locations)
      locations = Array(locations) if not locations.is_a? Array
      api_request = "AddressValidateRequest"
      request = xml_for_verify_address(api_request, locations)
      gateway_commit(:verify_address, 'Verify', request, :live)
    end

    def zip_lookup(locations)
      locations = Array(locations) if not locations.is_a? Array
      api_request = "ZipCodeLookupRequest"
      request = xml_for_address_information_api(api_request, locations)
      gateway_commit(:zip_lookup, 'ZipCodeLookup',request, :live)
    end

    def city_state_lookup(locations)
      locations = Array(locations) if not locations.is_a? Array
      api_request = "CityStateLookupRequest"
      request = xml_for_address_information_api(api_request, locations)
      gateway_commit(:zip_lookup, 'CityStateLookup', request, :live)
    end


    def canned_verify_address_test
      locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371"   )]
      api_request = "AddressValidateRequest"
      request = xml_for_address_information_api(api_request, locations)
      gateway_commit(:verify_address, 'Verify', request, :test)
    end

    def canned_zip_lookup_test
      locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371"   )]
      api_request = "ZipCodeLookupRequest"
      request = xml_for_address_information_api(api_request, locations)
      gateway_commit(:zip_lookup, 'ZipCodeLookup', request, :test)
    end

    def canned_city_state_lookup_test
      locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371")]
      api_request = "CityStateLookupRequest"
      request = xml_for_address_information_api(api_request, locations)
      gateway_commit(:zip_lookup, 'CityStateLookup', request, :test)
    end

    # XML from  Builder::XmlMarkup.new
    def xml_for_address_information_api(api_request, locations)
      xm = Builder::XmlMarkup.new
      xm.tag!("#{api_request}", "USERID"=>"#{@username}") do
        locations.each_index do |id|
          l=locations[id]
          xm.Address("ID" => "#{id}") do
            xm.FirmName(l.firm_name)
            xm.Address1(l.address1)
            xm.Address2(l.address2)
            if api_request !="CityStateLookupRequest"
              xm.City(l.city)
              xm.State(l.state)
            end
            if api_request != "ZipCodeLookupRequest"
              xm.Zip5(l.zip5)
              xm.Zip4(l.zip4)
            end
          end
        end
      end
    end

    # Parses the XML into an array broken up by each address.
    # For verify_address :verified will be false if multiple address were found.
    def parse_address_information(xml)
      i = 0
      list_of_verified_addresses = []
      (Hpricot.parse(xml)/:address).each do |address|
        i+=1
        h = {}
        #Check if there was an error in an address element
        if address.search("error") != []
          RAILS_DEFAULT_LOGGER.info("Address number #{i} has the error '#{address.search("description").inner_html}' please fix before continuing")

          return "Address number #{i} has the error '#{address.search("description").inner_html}' please fix before continuing"
        end
        if address.search("ReturnText") != []
          h[:verified] = false
        else
          h[:verified] =true
        end
        address.children.each { |elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.blank? }
        list_of_verified_addresses << h
      end
      #Check if there was an error in the basic XML formating
      if list_of_verified_addresses == []
        error =Hpricot.parse(xml)/:error
        return  error.search("description").inner_html
      end
      return list_of_verified_addresses
    end

  end
end