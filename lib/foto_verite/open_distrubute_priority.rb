module  FotoVerite
  module OpenDistrubutePriority

    MAX_RETRIES = 3

    LIVE_DOMAIN = 'secure.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    TEST_DOMAIN =  'secure.shippingapis.com'

    TEST_RESOURCE = '/ShippingAPITest.dll'

    API_CODES = {:open_distrubute_priority => "OpenDistributePriority"}

    def open_distrubute_priority(orgin, destination, package_weight_in_ounces, permit_number, issued_by, mail_type, image_type, label_type=1, options={})
      @package_weight_in_ounces = package_weight_in_ounces
      @origin = origin
      @destination = destination
      @permit_number = permit_number
      @issued_by =issued_by
      @mail_type = mail_type
      @image_type = image_type
      @options =options
      request = open_distrubute_priority_xml
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_open_distrubute_priority_xml(:open_distrubute_priority, request, image_type, false)
    end

    def open_distrubute_priority_canned_test_1
      @origin = Location.new( :name=> "John Smith",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      @destination =Location.new( :name=> "Fairfax Post Office",  :address2 =>"10660 Page Ave",  :state => 'VA', :city => 'Fairfax', :zip5 => "22030", :facility_type => "DDU")
      @permit_number = "1"
      @issued_by ="21718"
      @mail_type = "Letters"
      @image_type = "PDF"
      @package_weight_in_ounces = 1
      @options = {:address_service => true}
      request= open_distrubute_priority_xml
      commit_open_distrubute_priority_xml(:open_distrubute_priority, request, @image_type, false)
    end


    def open_distrubute_priority_xml
      xm = Builder::XmlMarkup.new
      xm.tag!("OpenDistributePriorityRequest", "USERID"=>"#{@username}") do
        xm.PermitNumber(@permit_number)
        xm.PermitIssuingPOZip5(@issued_by)
        xm.FromName(@origin.name)
        xm.FromFirm(@origin.firm_name)
        xm.FromAddress1(@origin.address1) #Used for an apartment or suite number. Yes the API is a bit fucked.
        xm.FromAddress2(@origin.address2)
        xm.FromCity(@origin.city)
        xm.FromState(@origin.state)
        xm.FromZip5(@origin.zip5)
        xm.FromZip4(@origin.zip4)
        xm.POZipCode(@options[:POZipCode])
        xm.ToFacilityName(@destination.name)
        xm.ToFacilityAddress1(@destination.address1)
        xm.ToFacilityAddress2(@destination.address2)
        xm.ToFacilityCity(@destination.city)
        xm.ToFacilityState(@destination.state)
        xm.ToFacilityZip5(@destination.zip5)
        xm.ToFacilityZip4(@destination.zip4)
        xm.FacilityType(@destination.facility_type)
        xm.MailClassEnclosed(@mail_type)
        xm.MailClassOther(@options[:other])
        xm.WeightInPounds("0")
        xm.WeightInOunces(@package_weight_in_ounces)
        xm.ImageType(@image_type)
        xm.SeparateReceiptPage(@options[:seperate])
        xm.LabelDate(@options[:label_date])
        xm.AllowNonCleansedFacilityAddr("false")
      end
    end

    def parse_open_distrubute_priority(xml, image_type)
      if image_type == "TIF"
        image_type = "image/tif"
      else
        image_type = "application/pdf"
      end
      parse = Hpricot.parse(xml)/:error
      if parse != []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      else
        number = Hpricot.parse(xml)/:openDistributeprioritynumber
        label = Hpricot.parse(xml)/:opendistributeprioritylabel
        return {:image_type => image_type, :number => number.inner_html, :label => label.inner_html}
      end
    end


    private
    def commit_open_distrubute_priority_xml(action, request, image_type, test=false)
      retries = MAX_RETRIES
      begin
        #If and when their testing resource works again this will be useful tertiary command
        url = URI.parse(test ?  "https://#{LIVE_DOMAIN}#{TEST_RESOURCE}" : "https://#{LIVE_DOMAIN}#{LIVE_RESOURCE}")
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data({'API' => API_CODES[action], 'XML' => request})
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

        parse_open_distrubute_priority(response.body, image_type)
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response.body}")
        return "USPS plugin settings are wrong #{response.body}"
      end
    end
  end
end
