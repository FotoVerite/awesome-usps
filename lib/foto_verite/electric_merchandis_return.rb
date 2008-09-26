module FotoVerite
  module ElectricMerchandisReturn

    def merch_return(service_type, customer, retailer, permit_number, post_office, postage_delivery_unit,  ounces, image_type, api_request = "EMRSV3.0Request", options={})
      request = merch_return_xml(api_request, service_type, customer, retailer, permit_number, post_office, postage_delivery_unit,  ounces, image_type, options)
      #YES THE API IS SO STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      gateway_commit(:merchandise_return, "MerchandiseReturnV3", request, :ssl, image_type)
    end

    def canned_merch_return_test
      service_type ="Priority"
      customer = Location.new( :name=> "Craig Ingle",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      retailer =Location.new( :name=> "XYZ Corp.",  :address2 =>"1100 West Avenue")
      permit_number = "293829"
      post_office = Location.new(  :state => 'NY', :city => 'New York', :zip5 => '10018')
      postage_delivery_unit =  Location.new(  :state => 'NY', :city => 'New York', :address2 =>"223 W 38TH ST" )
      ounces = "52"
      options = {:RMA => "13456", :insurance => "500", :confirmation => "true"}
      image_type ="PDF"
      api_request = "EMRSV3.0CertifyRequest"
      request = merch_return_xml(api_request, service_type, customer, retailer, permit_number, post_office, postage_delivery_unit,  ounces, image_type, options)
      gateway_commit(:merchandise_return_certify, 'MerchReturnCertifyV3', request, :ssl, image_type)
    end

    private
    def merch_return_xml(api_request, service_type, customer, retailer, permit_number, post_office, postage_delivery_unit,  ounces, image_type, options)
      xm = Builder::XmlMarkup.new
      xm.tag!("#{api_request}", "USERID"=>"#{@username}") do
        xm.CustomerName(customer.name)
        xm.CustomerAddress(customer.address2)
        xm.CustomerCity(customer.city) #Used for an apartment or suite number. Yes the API is a bit fucked.
        xm.CustomerState(customer.state)
        xm.CustomerZip5(customer.zip5)
        xm.RetailerName(retailer.name)
        xm.RetailerAddress(retailer.address2)
        xm.PermitNumber(permit_number)
        xm.PermitIssuingPOCity(post_office.city)
        xm.PermitIssuingPOState(post_office.state)
        xm.PermitIssuingPOZip5(post_office.zip5)
        xm.PDUPOBox(postage_delivery_unit.address2)
        xm.PDUCity(postage_delivery_unit.city)
        xm.PDUState(postage_delivery_unit.state)
        xm.PDUZip5(postage_delivery_unit.zip5)
        xm.PDUZip4(postage_delivery_unit.zip4)
        xm.ServiceType(service_type)
        xm.DeliveryConfirmation(options[:confirmation] || "false")
        xm.InsuranceValue(options[:insurance_value])
        xm.MailingAckPackageID(options[:id])
        xm.WeightInPounds("0")
        xm.WeightInOunces(ounces)
        xm.RMA(options[:rma])
        xm.ImageType(image_type)
        xm.SenderName(options[:sender_name])
        xm.SenderEMail(options[:sender_email])
        xm.RecipientName(options[:recipient_name])
        xm.RecipientEMail(options[:recipient_email])
        xm.RMABarcode(options[:barcode])
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

  end
end
