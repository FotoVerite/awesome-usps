module  FotoVerite
  module InternationalMailLabels

    MAX_RETRIES = 3

    LIVE_DOMAIN = 'secure.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'


    API_CODES = {:express_mail => "ExpressMailIntl",
      :express_mail_certify => "ExpressMailIntlCertify",
      :priority_mail => "PriorityMailIntl",
      :priority_mail_certify => "PriorityMailIntlCertify",
      :first_class_mail => "FirstClassMailIntl",
    :first_class_mail_certify => "FirstClassMailIntlCertify"}

    RESPONSE = {:express_mail => "ExpressMailIntlResponse",
      :express_mail_certify => "ExpressMailIntlCertifyResponse",
      :priority_mail => "PriorityMailIntlResponse",
      :priority_mail_certify => "PriorityMailIntlCertifyResponse",
      :first_class_mail => "FirstClassMailIntlResponse",
    :first_class_mail_certify => "FirstClassMailIntlCertifyResponse"}

    def express_mail_international_label(sender, receiver, items, content_type, image_type, po_box_flag ="N",
      image_layout="ALLINONEFILE", label_type="1", options={})
      @sender = sender
      @receiver = receiver
      @items = items
      Array(@items) if not @items.is_a? Array
      @po_box_flag =po_box_flag
      @content_type = content_type
      @image_layout = image_layout
      @label_type =label_type
      @image_type = image_type
      @options =options
      @api = "ExpressMailIntlRequest"
      request = international_mail_labels_xml
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_international_mail_labels_xml(:express_mail, request, image_type, false)
    end

    def canned_express_mail_international_label_test
      @sender = Location.new( :first_name=> "John",  :last_name => "Berger", :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770', :phone => "2016585989")
      @receiver =Location.new( :name=> "Fairfax Post Office",  :address2 =>"10660 Page Ave",   :city => 'Tokyo', :zip5 => "22030", :country => "Japan" )

      @po_box_flag ="N"
      @content_type = "GIFT"
      @image_layout="ALLINONEFILE"
      @image_type = "PDF"
      @items = [InternationalItem.new(:ounces => 50, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00), InternationalItem.new(:ounces => 40, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00)]
      @api = "ExpressMailIntlCertifyRequest"
      @options ={}
      request= international_mail_labels_xml
      commit_international_mail_labels_xml(:express_mail_certify, request, @image_type, true)
    end
    def priority_mail_international_label(sender, receiver, items, content_type, image_type, po_box_flag ="N",
      image_layout="ALLINONEFILE", label_type="1", options={})
      @sender = sender
      @receiver = receiver
      @items = items
      Array(@items) if not @items.is_a? Array
      @po_box_flag =po_box_flag
      @content_type = content_type
      @image_layout = image_layout
      @label_type =label_type
      @image_type = image_type
      @options =options
      @api = "PriorityMailIntlRequest"
      request = international_mail_labels_xml
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_international_mail_labels_xml(:priority_mail, request, image_type, false)
    end

    def canned_priority_mail_international_label_test
      @sender = Location.new( :first_name=> "John",  :last_name => "Berger", :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770', :phone => "2016585989")
      @receiver =Location.new( :name=> "Fairfax Post Office",  :address2 =>"10660 Page Ave",   :city => 'Tokyo', :zip5 => "22030", :country => "Japan" )

      @po_box_flag ="N"
      @content_type = "GIFT"
      @image_layout="ALLINONEFILE"
      @image_type = "PDF"
      @items = [InternationalItem.new(:ounces => 50, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00), InternationalItem.new(:ounces => 40, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00)]
      @api = "PriorityMailIntlCertifyRequest"
      @options ={}
      request= international_mail_labels_xml
      commit_international_mail_labels_xml(:priority_mail_certify, request, @image_type, true)
    end

    def first_class_international_label(sender, receiver, items, content_type, image_type, po_box_flag ="N",
      image_layout="ALLINONEFILE", label_type="1", options={})
      @sender = sender
      @receiver = receiver
      @items = items
      Array(@items) if not @items.is_a? Array
      @po_box_flag =po_box_flag
      @content_type = content_type
      @image_layout = image_layout
      @label_type =label_type
      @image_type = image_type
      @options =options
      @api = "FirstClassMailIntlRequest"
      request = first_class_international_mail_labels_xml
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_international_mail_labels_xml(:first_class_mail, request, image_type, false)
    end

    def canned_first_class_mail_international_label_test
      @sender = Location.new( :first_name=> "John",  :last_name => "Berger", :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770', :phone => "2016585989")
      @receiver =Location.new( :name=> "Fairfax Post Office",  :address2 =>"10660 Page Ave",   :city => 'Tokyo', :zip5 => "22030", :country => "Japan" )

      @po_box_flag ="N"
      @content_type = "GIFT"
      @image_layout="ALLINONEFILE"
      @image_type = "PDF"
      @items = [InternationalItem.new(:ounces => 10, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00), InternationalItem.new(:ounces => 10, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00)]
      @api = "FirstClassMailIntlCertifyRequest"
      @options ={}
      request= first_class_international_mail_labels_xml
      commit_international_mail_labels_xml(:first_class_mail_certify, request, @image_type, true)
    end

    private
    def international_mail_labels_xml
      xm = Builder::XmlMarkup.new
      xm.tag!("#{@api}", "USERID"=>"#{@username}") do
        xm.Option
        xm.ImageParameters
        xm.FromFirstName(@sender.first_name)
        xm.FromMiddleInitial(@options[:middle_initial])
        xm.FromLastName(@sender.last_name)
        xm.FromFirm(@sender.firm_name)
        xm.FromAddress1(@sender.address1)
        xm.FromAddress2(@sender.address2)
        xm.FromUrbanization(@sender.from_urbanization)
        xm.FromCity(@sender.city)
        xm.FromState(@sender.state)
        xm.FromZip5(@sender.zip5)
        xm.FromZip4(@sender.zip4)
        xm.FromPhone(@sender.phone)
        xm.FromCustomsReference(@options[:from_customs_reference])
        xm.ToName(@receiver.name)
        xm.ToFirm(@receiver.firm_name)
        xm.ToAddress1(@receiver.address1)
        xm.ToAddress2(@receiver.address2)
        xm.ToAddress3(@receiver.address3)
        xm.ToCity(@receiver.city)
        xm.ToProvince(@receiver.province)
        xm.ToCountry(@receiver.country)
        xm.ToPostalCode(@receiver.postal_code)
        xm.ToPOBoxFlag(@po_box_flag)
        xm.ToPhone(@receiver.phone)
        xm.ToFax(@options[:fax])
        xm.ToEmail(@options[:email])
        xm.ToCustomsReference(@options[:to_customs_reference])
        xm.NonDeliveryOption(@options[:non_delivery_option])
        xm.AltReturnAddress1(@options[:alt_return_address1])
        xm.AltReturnAddress2(@options[:alt_return_address2])
        xm.AltReturnAddress3(@options[:alt_return_address3])
        xm.AltReturnCountry(@options[:alt_return_country])
        xm.Container(@options[:container])
        xm.ShippingContents do
          @items.each do |item|
            xm.ItemDetail do
              xm.Description(item.description)
              xm.Quantity(item.quantity)
              xm.Value(item.value)
              xm.NetPounds(item.pounds)
              xm.NetOunces(item.ounces)
              xm.HSTariffNumber(item.tariff_number)
              xm.CountryOfOrigin(item.country)
            end
          end
        end
        xm.InsuredNumber(@options[:insurance_number])
        xm.InsuredAmount(@options[:insured_amount])
        xm.Postage(@options[:postage])
        xm.GrossPounds("0")
        xm.GrossOunces(@items.sum {|item| item.ounces.to_f})
        xm.ContentType(@content_type)
        xm.ContentTypeOther(@options[:other])
        xm.Agreement("Y")
        xm.Comments(@options[:comments])
        xm.LicenseNumber(@options[:license_number])
        xm.CertificateNumber(@options[:certificate_number])
        xm.InvoiceNumber(@options[:invoice_number])
        xm.ImageType(@image_type)
        xm.ImageLayout(@image_layout)
        xm.CustomerRefNo(@options[:reference_number])
        xm.POZipCode(@options[:po_zip_code])
        xm.LabelDate(@options[:label_date])
        xm.HoldForManifest(@options[:hold])
      end
    end

    def first_class_international_mail_labels_xml
      xm = Builder::XmlMarkup.new
      xm.tag!("#{@api}", "USERID"=>"#{@username}") do
        xm.Option
        xm.ImageParameters
        xm.FromFirstName(@sender.first_name)
        xm.FromMiddleInitial(@options[:middle_initial])
        xm.FromLastName(@sender.last_name)
        xm.FromFirm(@sender.firm_name)
        xm.FromAddress1(@sender.address1)
        xm.FromAddress2(@sender.address2)
        xm.FromUrbanization(@sender.from_urbanization)
        xm.FromCity(@sender.city)
        xm.FromState(@sender.state)
        xm.FromZip5(@sender.zip5)
        xm.FromZip4(@sender.zip4)
        xm.FromPhone(@sender.phone)
        xm.ToName(@receiver.name)
        xm.ToFirm(@receiver.firm_name)
        xm.ToAddress1(@receiver.address1)
        xm.ToAddress2(@receiver.address2)
        xm.ToAddress3(@receiver.address3)
        xm.ToCity(@receiver.city)
        xm.ToProvince(@receiver.province)
        xm.ToCountry(@receiver.country)
        xm.ToPostalCode(@receiver.postal_code)
        xm.ToPOBoxFlag(@po_box_flag)
        xm.ToPhone(@receiver.phone)
        xm.ToFax(@options[:fax])
        xm.ToEmail(@options[:email])
        xm.FirstClassMailType(@options[:first_class_mail_type])
        xm.ShippingContents do
          @items.each do |item|
            xm.ItemDetail do
              xm.Description(item.description)
              xm.Quantity(item.quantity)
              xm.Value(item.value)
              xm.NetPounds(item.pounds)
              xm.NetOunces(item.ounces)
              xm.HSTariffNumber(item.tariff_number)
              xm.CountryOfOrigin(item.country)
            end
          end
        end
        xm.GrossPounds("0")
        xm.GrossOunces(@items.sum {|item| item.ounces.to_f})
        xm.Machinable(@options[:machinable])
        xm.ContentType(@content_type)
        xm.ContentTypeOther(@options[:other])
        xm.Agreement("Y")
        xm.Comments(@options[:comments])
        xm.ImageType(@image_type)
        xm.ImageLayout(@image_layout)
        xm.LabelDate(@options[:label_date])
        xm.HoldForManifest(@options[:hold])
      end
    end


    def parse_internation_label(xml, image_type, response)
      label_hash = {}
      image_type = image_mime(image_type)
      parse = Hpricot.parse(xml)/:error
      if parse != []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return parse.inner_html
      end
      parse = Hpricot.parse(xml).search("#{response.downcase}")
      parse.each do |detail|
        h = {}
        detail.children.each { |elem| label_hash[elem.name.to_sym] = elem.inner_text unless elem.inner_text.blank? }
      end
      label_hash[:image_type] = image_type
      return label_hash
    end

    def image_mime(image_type)
      if image_type == "TIF"
        image_type = "image/tif"
      else
        image_type = "application/pdf"
      end
    end
    
    def commit_international_mail_labels_xml(action, request, image_type, test=false)
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

        parse_internation_label(response.body, image_type, RESPONSE[action])
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response.body}")
        return "USPS plugin settings are wrong #{response.body}"
      end
    end
  end
end
