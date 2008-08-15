module FotoVerite
  module ServiceStandard
    MAX_RETRIES = 3

    LIVE_DOMAIN = 'production.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    TEST_DOMAIN ='testing.shippingapis.com'
    TEST_RESOURCE = '/ShippingAPITest.dll'

    API_CODES ={
      :priority_mail => 'PriorityMail',
      :standard => 'StandardB',
      :express => 'ExpressMailCommitment'
    }

    # Takes your package tracking number and returns information for the USPS web API
    def priority_mail_estimated_time(origin, destination)
      @origin = orgin
      @destination=destination
      request = xml_for_estimated_time_for_delivery("PriorityMailRequest")
      commit_service_standard_request(:priority_mail, request ,false)
    end

    def standard_mail_estimated_time(origin, destination)
      @origin = orgin
      @destination=destination
      request = xml_for_estimated_time_for_delivery("StandardBRequest")
      commit_service_standard_request(:standard, request ,false)
    end

    def express_mail_commitment(origin, destination, date=nil)
      @origin = orgin
      @destination=destination
      @date = date
      request = xml_for_estimated_time_for_delivery("ExpressMailCommitmentRequest")
      commit_service_standard_request(:express, request ,false)
    end

    def canned_standard_mail_estimated_time_test
      @origin =  Location.new(  :zip5 => '4')
      @destination = Location.new( :zip5 => '4')
      request = xml_for_estimated_time_for_delivery("PriorityMailRequest")
      commit_service_standard_request(:priority_mail, request ,true)
    end

    def canned_priority_mail_estimated_time_test
      @origin =  Location.new(  :zip5 => '4')
      @destination = Location.new( :zip5 => '4')
      request = xml_for_estimated_time_for_delivery("PriorityMailRequest")
      commit_service_standard_request(:standard, request ,true)
    end

    def canned_express_mail_commitment_test
      @origin= Location.new(  :zip5 =>'20770')
      @destination=Location.new( :zip5 =>'11210')
      @date = '05-Aug-2004'
      request = xml_for_estimated_time_for_delivery("ExpressMailCommitmentRequest")
      commit_service_standard_request(:express, request ,true)
    end

    # XML from a straight string.
    # "<TrackFieldRequest USERID='#{@username}'><TrackID ID='#{@tracking_number}'></TrackID></TrackFieldRequest>"
    def xml_for_estimated_time_for_delivery(type_of_request)
      xm = Builder::XmlMarkup.new
      xm.tag!(type_of_request, "USERID"=>"#{@username}") do
        xm.OriginZIP(@origin.zip5)
        xm.DestinationZIP(@destination.zip5)
        xm.Date(@date) if type_of_request == "ExpressMailCommitmentRequest"
      end
    end

    # Parses the XML into an array broken up by each event.
    # Example of returned array
    def parse_service(xml)
      event_list = []
      parse = Hpricot.parse(xml)/:error
      if parse != []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      else
        return  parse = (Hpricot.parse(xml)/:days).inner_html
      end
    end

    def parse_express(xml)
      parse = Hpricot.parse(xml)/:error
      if parse != []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      else
        i= 0
        location_list = []
        (Hpricot.parse(xml)/:location).each do |location|
          i+=1
          h = {}
          location.children.each {|elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.blank?}
          location_list << h
        end
        return   location_list
      end
    end

    private
    def commit_service_standard_request(action, request, test = false)
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
        if action == :express
          parse_express(response.body)
        else
          parse_service(response.body)
        end
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response}")
      end
    end

  end
end
