module AwesomeUsps
  module ElectricMerchandisReturn

    def merch_return(service_type, window, customer, retailer, permit_number, post_office, postage_delivery_unit,  ounces, image_type, api_request = "EMRSV4.0Request", options={})
      request = merch_return_xml(api_request, window, service_type, customer, retailer, permit_number, post_office, postage_delivery_unit,  ounces, image_type, options)
      #YES THE API IS SO STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      gateway_commit(:merchandise_return, "MerchandiseReturnV4", request, :ssl, image_type)
    end

    private
    def merch_return_xml(api_request, window, service_type, customer, retailer, permit_number, post_office, postage_delivery_unit,  ounces, image_type, options)
      builder = Nokogiri::XML::Builder.new do |xm|
        xm.send("#{api_request}", "USERID"=>"#{@username}") do
          xm.Option(window)
          xm.CustomerName(customer.name)
          xm.CustomerAddress1(customer.address1)
          xm.CustomerAddress2(customer.address2)
          xm.CustomerCity(customer.city)
          xm.CustomerState(customer.state)
          xm.CustomerZip5(customer.zip5)
          xm.CustomerZip4(customer.zip4)
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
          xm.RMAPICFlag(options[:rma].nil? ? false : true)
          xm.ImageType(image_type)
          xm.SenderName(options[:sender_name])
          xm.SenderEMail(options[:sender_email])
          xm.RecipientName(options[:recipient_name])
          xm.RecipientEMail(options[:recipient_email])
          xm.RMABarcode(options[:barcode])
        end
      end
      return builder.doc.root.to_xml
    end


    def parse_merch_return_label(xml, image_type)
      doc = Nokogiri::XML(xml)
      mime_type = image_mime_type image_type
      raise(USPSResponseError, doc.search('Description').inner_html) unless doc.xpath("Error").empty?
      label = doc.search("MerchandiseReturnLabel")
      cost = doc.search("InsuranceCost")
      postnet = doc.search("PostNew")
      confirmation_number = doc.search("DeliveryConfirmationNumber").empty? ? "none" : doc.search("DeliveryConfirmationNumber")
      return {:image_type => mime_type, :confirmation_number => confirmation_number.inner_html, :label => label.inner_html, :cost => cost.inner_html, :postnet => postnet.inner_html}
    end

  end
end
