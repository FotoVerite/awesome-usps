module  FotoVerite
  module DeliveryAndSignatureConfirmation

    MAX_RETRIES = 3

    LIVE_DOMAIN = 'secure.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    API_CODES = {:delivery =>'DeliveryConfirmationV3',
      :delivery_confirmation_certify => "DelivConfirmCertifyV3",
      :signature => "SignatureConfirmationV3",
    :signature_confirmation_certify => "SignatureConfirmCertifyV3"}

    def delivery_confirmation_label(origin, destination, service_type, image_type, label_type=1, options={})
      @origin = origin
      @destination = destination
      @service_type = service_type
      @image_type =image_type
      @label_type = label_type
      @options = options
      @api = "DeliveryConfirmationV3.0Request"
      request = confirmation_xml
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_confirmation_xml(:delivery, request, image_type, false)
    end

    def signature_confirmation_label(origin, destination, service_type, image_type, label_type=1, options={})
      @origin = origin
      @destination = destination
      @service_type = service_type
      @image_type =image_type
      @label_type = label_type
      @options = options
      @api = "SignatureConfirmationV3.0Request"
      request = confirmation_xml
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_confirmation_xml(:signature, request, image_type, false)
    end

    protected

    def canned_delivery_confirmation_label_test
      @origin = Location.new( :name=> "John Smith",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      @destination =Location.new( :name=> "Joe Customer",  :address2 =>"136 Linwood Plz",  :state => 'NJ', :city => 'Fort Lee', :zip5 => "07024")
      @service_type = "Priority"
      @image_type ="PDF"
      @label_type = 1
      @options = {:weight => 2}
      @api = "DelivConfirmCertifyV3.0Request"
      request = confirmation_xml
      commit_confirmation_xml(:delivery_confirmation_certify, request, @image_type, true)
    end



    def canned_signature_confirmation_label_test
      @origin = Location.new( :name=> "John Smith",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      @destination =Location.new( :name=> "Joe Customer",  :address2 =>"136 Linwood Plz",  :state => 'NJ', :city => 'Fort Lee', :zip5 => "07024")
      @service_type = "Priority"
      @image_type ="PDF"
      @label_type = 1
      @options = {:weight => 2}
      @api = "SignatureConfirmCertifyV3.0Request"
      request = confirmation_xml
      commit_confirmation_xml(:signature_confirmation_certify, request, @image_type, true)
    end

    private
    def confirmation_xml
      xm = Builder::XmlMarkup.new
      xm.tag!(@api, "USERID"=>"#{@username}") do
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
        xm.WeightInOunces(@options[:weight_in_ounces])
        xm.ServiceType(@service_type)
        xm.SeparateReceiptPage(@options[:seperate])
        xm.POZipCode(@options[:po_zip_code])
        xm.ImageType(@image_type)
        xm.LabelDate(@options[:label_date])
        xm.CustomerRefNo(@options[:customer_reference_number])
        xm.AddressServiceRequested(@options[:address_service])
        xm.SenderName(@options[:sender_name])
        xm.SenderEMail(@options[:sender_email])
        xm.RecipientName(@options[:recipient_name])
        xm.RecipientEmail(@options[:recipient_email])
      end
    end

    def parse_confirmation_label(xml, image_type)
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
        number = Hpricot.parse(xml)/:deliveryconfirmationnumber
        label = Hpricot.parse(xml)/:deliveryconfirmationlabel
        return {:image_type => image_type, :number => number.inner_html, :label => label.inner_html}
      end
    end


    def commit_confirmation_xml(action, request, image_type, test=false)
      retries = MAX_RETRIES
      begin
        #If and when their testing resource works again this will be useful tertiary command
        url = URI.parse("https://#{LIVE_DOMAIN}#{LIVE_RESOURCE}")
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
        parse_confirmation_label(response.body, image_type)
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response}")
        return "USPS plugin settings are wrong #{response}"
      end
    end
  end
end
