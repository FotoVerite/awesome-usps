module FotoVerite
  module ElectricMerchandisReturn

    MAX_RETRIES = 3

    LIVE_DOMAIN = 'secure.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    API_CODES = {:live =>'MerchandiseReturnV3',
    :test => "MerchReturnCertifyV3"}

    def merch_return(service_type, customer, retailer, permit_number, post_offcice, postage_delivery_unit,  ounces, image_type, options={})
      @service_type =service_type
      @customer = customer
      @retailer = retailer
      @permit_number = permit_number
      @post_offcice =post_offcice
      @postage_delivery_unit = postage_delivery_unit
      @ounces = ounces
      @image_type= image_type
      @options = options
      @api = "EMRSV3.0Request"
      request = merch_return_xml
      #YES THE API IS SO STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_merch_return_xml(:live, request, image_type, false)
    end

    def merch_return_canned_test
      @service_type ="Priority"
      @customer = Location.new( :name=> "Craig Ingle",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      @retailer =Location.new( :name=> "XYZ Corp.",  :address2 =>"1100 West Avenue")
      @permit_number = "293829"
      @post_office = Location.new(  :state => 'NY', :city => 'New York', :zip5 => '10018')
      @postage_delivery_unit =  Location.new(  :state => 'NY', :city => 'New York', :address2 =>"223 W 38TH ST" )
      @ounces = "52"
      @options = {:RMA => "13456", :insurance => "500", :confirmation => "true"}
      @image_type ="PDF"
      @api = "EMRSV3.0CertifyRequest"
      request = merch_return_xml
      commit_merch_return_xml(:test, request, @image_type, true)
    end


    def merch_return_xml
      xm = Builder::XmlMarkup.new
      xm.tag!("#{@api}", "USERID"=>"#{@username}") do
        xm.CustomerName(@customer.name)
        xm.CustomerAddress(@customer.address2)
        xm.CustomerCity(@customer.city) #Used for an apartment or suite number. Yes the API is a bit fucked.
        xm.CustomerState(@customer.state)
        xm.CustomerZip5(@customer.zip5)
        xm.RetailerName(@retailer.name)
        xm.RetailerAddress(@retailer.address2)
        xm.PermitNumber(@permit_number)
        xm.PermitIssuingPOCity(@post_office.city)
        xm.PermitIssuingPOState(@post_office.state)
        xm.PermitIssuingPOZip5(@post_office.zip5)
        xm.PDUPOBox(@postage_delivery_unit.address2)
        xm.PDUCity(@postage_delivery_unit.city)
        xm.PDUState(@postage_delivery_unit.state)
        xm.PDUZip5(@postage_delivery_unit.zip5)
        xm.PDUZip4(@postage_delivery_unit.zip4)
        xm.ServiceType(@service_type)
        xm.DeliveryConfirmation(@options[:confirmation] || "false")
        xm.InsuranceValue(@options[:insurance])
        xm.MailingAckPackageID(@options[:id])
        xm.WeightInPounds("0")
        xm.WeightInOunces(@ounces)
        xm.RMA(@options[:rma])
        xm.ImageType(@image_type)
        xm.SenderName(@options[:sender_name])
        xm.SenderEMail(@options[:sender_email])
        xm.RecipientName(@options[:recipient_name])
        xm.RecipientEMail(@options[:recipient_email])
        xm.RMABarcode(@options[:barcode])
      end
    end


    def parse_merch_return_label(xml, image_type)
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
        label = Hpricot.parse(xml)/:merchandisereturnlabel
        cost = Hpricot.parse(xml)/:insurancecost
        postnet = Hpricot.parse(xml)/:postnet
        confirmation_number = Hpricot.parse(xml)/:deliveryconfirmationnumber
        confirmation_number = "none" if confirmation_number == []
        return {:image_type => image_type, :confirmation_number => confirmation_number.inner_html, :label => label.inner_html, :cost => cost.inner_html, :postnet => postnet.inner_html}
      end
    end


    private
    def commit_merch_return_xml(action, request, image_type, test=false)
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
        parse_merch_return_label(response.body, image_type)
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response}")
        return "USPS plugin settings are wrong #{response}"
      end
    end
  end
end
