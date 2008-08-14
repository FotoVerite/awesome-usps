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
      @locations = locations
      @locations.to_a if not  @locations.is_a? Array
      @api = "AddressValidateRequest"
      request = xml_for_verify_address
      commit_address_information_request(:verify_address, request ,false)
    end

    def verify_address_canned_test
      @locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371"   )]
      @api = "AddressValidateRequest"
      request = xml_for_address_information_api
      commit_address_information_request(:verify_address, request ,true)
    end

    def zip_lookup(locations)
      @locations = locations
      @locations = Array(@locations) if not @locations.is_a? Array
      @api = "ZipCodeLookupRequest"
      request = xml_for_address_information_api
      commit_address_information_request(:zip_lookup, request ,false)
    end

    def zip_lookup_canned_test
      @locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371"   )]
      @api = "ZipCodeLookupRequest"
      request = xml_for_address_information_api
      commit_address_information_request(:zip_lookup, request ,true)
    end

    def city_state_lookup(locations)
      @locations = locations
      @locations = Array(@locations) if not @locations.is_a? Array
      @api = "CityStateLookupRequest"
      request = xml_for_address_information_api
      commit_address_information_request(:zip_lookup, request ,false)
    end

    def city_state_lookup_canned_test
      @locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371"   )]
      @api = "CityStateLookupRequest"
      request = xml_for_address_information_api
      commit_address_information_request(:zip_lookup, request ,true)
    end

    # XML from  Builder::XmlMarkup.new
    def xml_for_address_information_api
      xm = Builder::XmlMarkup.new
      xm.tag!("#{@api}", "USERID"=>"#{@username}") do
        @locations.each_index do |id|
          l=@locations[id]
          xm.Address("ID" => "#{id}") do
            xm.FirmName(l.firm_name)
            xm.Address1(l.address1)
            xm.Address2(l.address2)
            if @api !="CityStateLookupRequest"
              xm.City(l.city)
              xm.State(l.state)
            end
            if @api != "ZipCodeLookupRequest"
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


    private
    def commit_address_information_request(action, request, test = false)
      retries = MAX_RETRIES
      begin
        url = URI.parse(test ? "http://#{TEST_DOMAIN}#{TEST_RESOURCE}" : "http://#{LIVE_DOMAIN}#{LIVE_RESOURCE}")
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data({'API' => API_CODES[action], 'XML' => request})
        response = Net::HTTP.new(url.host, url.port)
        response.open_timeout = 5
        response.read_timeout = 5
        response.start
      rescue Timeout::Error
        if retries > 0
          retries -= 1
          retry
        else
          RAILS_DEFAULT_LOGGER.warn "The connection to the remote server timed out"
          return "We appoligize for the inconvience but our USPS service is busy at the moment. To retry please refresh the browser"

        end
      rescue SocketError
        RAILS_DEFAULT_LOGGER.error "There is a socket error with USPS plugin"
        return "We appoligize for the inconvience but there is a problem with our server. To retry please refresh the browser"
      end

      response = response.request(req)
      case response
      when Net::HTTPSuccess
        parse_address_information(response.body)
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response}")
      end
    end

  end
end
