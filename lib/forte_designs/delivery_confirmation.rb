module  ForteDesigns
  module DeliveryConfirmation

    MAX_RETRIES = 3

    LIVE_DOMAIN = 'secure.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    TEST_DOMAIN =  'secure.shippingapis.com'

    TEST_RESOURCE = '/ShippingAPITest.dll'

    API_CODE = 'DeliveryConfirmationV3'

    def delivery_confirmation(origin, destination, service_type, image_type, label_type=1, options={})
      @origin = origin
      @destination = destination
      @service_type = service_type
      @image_type =image_type
      @label_type = label_type
      @options = options
      request = delivery_xml
      commit_delivery_xml(:request, request ,false)
    end

    def delivery_xml
      xm = Builder::XmlMarkup.new
      xm.tag!("DeliveryConfirmationV3.0Request", "USERID"=>"#{@username}") do
        xm.Option(@label_type)
        xm.ImageParameters #Will be used in the future. Is a required tag.
        xm.FromName(@origin.name)
        xm.FromFirm(@origin.firm_name)
        xm.FromAddress1(@origin.address1) #Used for an apartment or suite number. Yes the API is a bit fucked.
        xm.FromAddress2(@origin.address2)
        xm.FromCity(@origin.city)
        xm.FromState(@origin.state)
        xm.FromZip5(@origin.zip5)
        xm.FromZip4(@origin.zip4)
        xm.ToName(@destination.name)
        xm.ToFirm(@destination.firm_name)
        xm.ToAddress1(@destination.address1)
        xm.ToAddress2(@destination.address2)
        xm.ToCity(@destination.city)
        xm.ToState(@destination.state)
        xm.ToZip5(@destination.zip5)
        xm.ToZip4(@destination.zip4)
        xm.WeightInOunces(@options[:weight])
        xm.ServiceType(@service_type)
        xm.SeparateReceiptPage(@options[:seperate])
        xm.POZipCode(@options[:po_zip_code])
        xm.ImageType(@image_type)
        xm.LabelDate(@options[:label_date])
        xm.CustomerRefNo(@options[:reference_number])
        xm.AddressServiceRequested(@options[:address_service])
        xm.SenderName(@options[:sender_name])
        xm.SenderEMail(@options[:sender_email])
        xm.RecipientName
      end
    end

    def delivery_canned_test_1
      @origin = Location.new( :name=> "John Smith",  :address2 => "475 L'Enfant Plaza, SW",  :state => 'DC', :city => 'Washington', :zip5 => '20260')
      @destination =Location.new( :name=> "Joe Customer", :address1 => "STE 201", :address2 => "6060 PRIMACY PKWY",  :state => 'TN', :city => 'MEMPHIS')
      @service_type = "Priority"
      @image_type ="TIF"
      @label_type = 1
      @options = {:weight => 2}
      request = delivery_xml
      commit_delivery_xml(:test, request ,true)
    end

    private
    def commit_delivery_xml(action, request, test = true)
      retries = MAX_RETRIES
      begin
        url = URI.parse(test ?  "https://#{LIVE_DOMAIN}#{TEST_RESOURCE}" : "https://#{LIVE_DOMAIN}#{LIVE_RESOURCE}")
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data({'API' => API_CODE, 'XML' => request})
        response = Net::HTTP.new(url.host, 443)
        response.use_ssl
        response.open_timeout = 5
        response.read_timeout = 5
        response.use_ssl = true
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
        return response
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response}")
        return "USPS plugin settings are wrong #{response}"
      end
    end
  end
end
