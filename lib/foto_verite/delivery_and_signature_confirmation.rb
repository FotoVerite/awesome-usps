module  FotoVerite
  module DeliveryAndSignatureConfirmation

    def delivery_confirmation_label(origin, destination, service_type, image_type, label_type=1, api_request = "DeliveryConfirmationV3.0Request", options={})
      request = confirmation_xml(api_request, origin, destination, service_type, image_type, label_type, options)
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_confirmation_xml(:delivery, 'DeliveryConfirmationV3', request,:ssl, image_type)
    end

    def signature_confirmation_label(origin, destination, service_type, image_type, label_type=1,
      api_request = "SignatureConfirmationV3.0Request", options={})
      request = confirmation_xml(api_request, origin, destination, service_type, image_type, label_type, options)
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      commit_confirmation_xml(:signature, 'SignatureConfirmationV3', request, :ssl, image_type)
    end


    def canned_delivery_confirmation_label_test
      origin = Location.new( :name=> "John Smith",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      destination =Location.new( :name=> "Joe Customer",  :address2 =>"136 Linwood Plz",  :state => 'NJ', :city => 'Fort Lee', :zip5 => "07024")
      service_type = "Priority"
      image_type ="PDF"
      label_type = 1
      options = {:weight => 2}
      api_request = "DelivConfirmCertifyV3.0Request"
      request = confirmation_xml(api_request, origin, destination, service_type, image_type, label_type, options)
      gateway_commit(:delivery_confirmation_certify,'DelivConfirmCertifyV3', request, :ssl, image_type)
    end

    def canned_signature_confirmation_label_test
      origin = Location.new( :name=> "John Smith",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      destination =Location.new( :name=> "Joe Customer",  :address2 =>"136 Linwood Plz",  :state => 'NJ', :city => 'Fort Lee', :zip5 => "07024")
      service_type = "Priority"
      image_type ="PDF"
      label_type = 1
      options = {:weight => 2}
      api_request = "SigConfirmCertifyV3.0Request"
      request = confirmation_xml(api_request, origin, destination, service_type, image_type, label_type, options)
      gateway_commit(:signature_confirmation_certify, 'SignatureConfirmationCertifyV3', request, :ssl, image_type)
    end

    private
    def confirmation_xml(api_request, origin, destination, service_type, image_type, label_type, options)
      xm = Builder::XmlMarkup.new
      xm.tag!(api_request, "USERID"=>"#{@username}") do
        xm.Option(label_type)
        xm.ImageParameters #Will be used in the future. Is a required tag.
        xm.FromName(origin.name)
        xm.FromFirm(origin.firm_name)
        xm.FromAddress1(origin.address1) #Used for an apartment or suite number. Yes the API is a bit fucked.
        xm.FromAddress2(origin.address2)
        xm.FromCity(origin.city)
        xm.FromState(origin.state)
        xm.FromZip5(origin.zip5)
        xm.FromZip4(origin.zip4)
        xm.ToName(destination.name)
        xm.ToFirm(destination.firm_name)
        xm.ToAddress1(destination.address1)
        xm.ToAddress2(destination.address2)
        xm.ToCity(destination.city)
        xm.ToState(destination.state)
        xm.ToZip5(destination.zip5)
        xm.ToZip4(destination.zip4)
        xm.WeightInOunces(options[:weight_in_ounces])
        xm.ServiceType(service_type)
        xm.SeparateReceiptPage(options[:seperate])
        xm.POZipCode(options[:po_zip_code])
        xm.ImageType(image_type)
        xm.LabelDate(options[:label_date])
        xm.CustomerRefNo(options[:customer_reference_number])
        xm.AddressServiceRequested(options[:address_service])
        xm.SenderName(options[:sender_name])
        xm.SenderEMail(options[:sender_email])
        xm.RecipientName(options[:recipient_name])
        xm.RecipientEMail(options[:recipient_email])
      end
    end

    def parse_confirmation_label(action, xml, image_type)
      if image_type == "TIF"
        image_type = "image/tif"
      else
        image_type = "application/pdf"
      end
      parse = Hpricot.parse(xml)/:error
      if parse != []
        RAILS_DEFAULT_LOGGER.info "#{xml}"
        return (Hpricot.parse(xml)/:description).inner_html
      elsif action == :signature_confirmation_certify || :signature
        number = Hpricot.parse(xml)/:signatureconfirmationnumber
        label = Hpricot.parse(xml)/:signatureconfirmationlabel
        return {:image_type => image_type, :number => number.inner_html, :label => label.inner_html}
      else
        number = Hpricot.parse(xml)/:deliveryconfirmationnumber
        label = Hpricot.parse(xml)/:deliveryconfirmationlabel
        return {:image_type => image_type, :number => number.inner_html, :label => label.inner_html}
      end
    end

  end
end
