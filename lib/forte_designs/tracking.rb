module ForteDesigns
  module Tracking
    MAX_RETRIES = 3

    LIVE_DOMAIN = 'production.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    TEST_DOMAINS = { #indexed by security; e.g. TEST_DOMAINS[USE_SSL[:rates]]
      true => 'secure.shippingapis.com',
      false => 'testing.shippingapis.com'
    }

    #TEST_RESOURCE = '/ShippingAPITest.dll' #TODO Look this up.

    API_CODE ='TrackV2'

    USE_SSL = {
      :tracking => false,
      :test => true
    }
    
    # Takes your package tracking number and returns information for the USPS web API
    def track(tracking_number)
      @tracking_number = tracking_number
      request = xml_for_tracking
      commit(:tracking, request ,false)
    end

    # XML from a straight string. 
    # "<TrackFieldRequest USERID='#{@username}'><TrackID ID='#{@tracking_number}'></TrackID></TrackFieldRequest>"
    def xml_for_tracking
      "<TrackFieldRequest USERID='#{@username}'><TrackID ID='#{@tracking_number}'></TrackID></TrackFieldRequest>"
    end

    # Parses the XML into an array broken up by each event.
    # Example of returned array
    def parse(xml)
      event_list = []
      parse = Hpricot.parse(xml)/:trackdetail
      if parse == []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      else
        parse.each do |detail|
          h = {}
          detail.children.each { |elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.blank? }
          event_list << h
        end
      end
      event_list
    end

    private
    def commit(action, request, test = false)
      retries = MAX_RETRIES
      begin
        url = URI.parse("http://#{LIVE_DOMAIN}#{LIVE_RESOURCE}")
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data({'API' => API_CODE, 'XML' => request})
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
      when Net::HTTPSuccess, Net::HTTPRedirection
        parse(response.body)
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response}")
      end
    end

  end
end
