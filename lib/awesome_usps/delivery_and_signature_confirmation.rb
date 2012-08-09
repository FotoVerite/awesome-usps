module AwesomeUsps
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

    private
    def confirmation_xml(api_request, origin, destination, service_type, image_type, label_type, options)
        builder = Nokogiri::XML::Builder.new do |xm|
          xm.send("#{api_request}", "USERID"=>"#{@username}") do
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
      builder.doc.root.to_xml
    end

    def parse_confirmation_label(action, xml, image_type)
      doc = Nokogiri::XML(xml)
      mime_type = image_mime_type image_type
      raise(USPSResponseError, doc.search('Description').inner_html) unless doc.xpath("Error").empty?
      if [:signature_confirmation_certify, :signature].include?(action)
        number = doc.search("SignatureConfirmationNumber")
        label = doc.search("SignatureConfirmationLabel")
        return {:image_type => mime_type, :number => number.inner_html, :label => label.inner_html}
      else
        number = doc.search("DeliveryConfirmationNumber")
        label = doc.search("DeliveryConfirmationLabel")
        return {:image_type => mime_type, :number => number.inner_html, :label => label.inner_html}
      end
    end

  end
end
