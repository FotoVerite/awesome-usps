module AwesomeUsps
  module AddressVerification

    # Examines address and fills in missing information. Address must include city & state or the zip to be processed.
    # Can do up to an array of five
    def verify_address(locations)
      locations = Array(locations) if not locations.is_a? Array
      api_request = "AddressValidateRequest"
      request = xml_for_address_information_api(api_request, locations)
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

    def xml_for_address_information_api(api_request, locations)
      builder = Nokogiri::XML::Builder.new do |xm|
        xm.send("#{api_request}", "USERID"=>"#{@username}") do
        locations.each_index do |id|
          l=locations[id]
          if api_request !="CityStateLookupRequest"
            xm.Address("ID" => "#{id}") do
              xm.FirmName(l.firm_name)
              xm.Address1(l.address1)
              xm.Address2(l.address2) 
              xm.City(l.city)
              xm.State(l.state)
              if api_request != "ZipCodeLookupRequest"
                xm.Zip5(l.zip5)
                xm.Zip4(l.zip4)
              end
            end
            else
              xm.ZipCode("ID" => "#{id}") do
                xm.Zip5 l.zip5
              end
             end
           end
         end
       end
      builder.doc.root.to_xml
    end

    # Parses the XML into an array broken up by each address.
    # For verify_address :verified will be false if multiple address were found.
    def parse_address_information(xml)
      doc = Nokogiri::XML(xml)
      list_of_verified_addresses = []
      doc.xpath("//Address|//ZipCode").each_with_index do |address, i|
        h = {}
        raise(USPSResponseError,"Address number #{i} has the error '#{address.search("Description").inner_html}' please fix before continuing") unless doc.search("Error").empty?
        address.children.each { |elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.empty? }
        list_of_verified_addresses << h
      end
      #Check if there was an error in the basic XML formating
      return list_of_verified_addresses
    end

  end
end