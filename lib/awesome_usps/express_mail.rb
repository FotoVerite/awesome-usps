module AwesomeUsps
  module ExpressMail

    def express_mail_label(orgin, destination, ounces, image_type, request_api = "ExpressMailLabelRequest", options={})
      request = express_mail_xml(request_api, orgin, destination, ounces, image_type, options)
      #YES THE API IS SO STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      gateway_commit(:express_mail_label, 'ExpressMailLabel', request, :ssl, image_type)
    end

    def canned_express_mail_label_test
      orgin = Location.new( :first_name=> "Craig", :last_name=>"Engle",  :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770', :phone => "2127658576")
      destination =Location.new( :firm_name=> "XYZ Corp.",  :address2 =>"1100 West Avenue", :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770')
      ounces = "50"
      image_type ="PDF"
      options = {}
      request_api = "ExpressMailLabelCertifyRequest"
      request = express_mail_xml(request_api, orgin, destination, ounces, image_type, options)
      gateway_commit(:express_mail_label_certify, 'ExpressMailLabelCertify', request, :ssl, image_type)
    end

    private
    def express_mail_xml(api_request, orgin, destination, ounces, image_type, options)
       builder = Nokogiri::XML::Builder.new do |xm|
        xm.send("#{api_request}", "USERID"=>"#{@username}") do
          xm.Option
          xm.EMCAAccount
          xm.EMCAPassword
          xm.ImageParameters
          xm.FromFirstName(orgin.name)
          xm.FromLastName(orgin.last_name)
          xm.FromFirm(orgin.firm_name)
          xm.FromAddress1(orgin.address1) #Used for an apartment or suite number. Yes the API is a bit fucked.
          xm.FromAddress2(orgin.address2)
          xm.FromCity(orgin.city)
          xm.FromState(orgin.state)
          xm.FromZip5(orgin.zip5)
          xm.FromZip4(orgin.zip4)
          xm.FromPhone(orgin.phone)
          xm.ToFirstName(destination.name)
          xm.ToLastName(destination.last_name)
          xm.ToFirm(destination.firm_name)
          xm.ToAddress1(destination.address1)
          xm.ToAddress2(destination.address2)
          xm.ToCity(destination.city)
          xm.ToState(destination.state)
          xm.ToZip5(destination.zip5)
          xm.ToZip4(destination.zip4)
          xm.ToPhone(destination.phone)
          xm.WeightInOunces(ounces)
          xm.FlatRate(options[:flat_rate])
          xm.StandardizeAddress(options[:standardize_address])
          xm.WaiverOfSignature(options[:waiver_signature])
          xm.NoHoliday(options[:no_holiday])
          xm.NoWeekend(options[:no_weekend])
          xm.SeparateReceiptPage(options[:seperate])
          xm.POZipCode(options[:po_zip_code])
          xm.ImageType(image_type)
          xm.LabelDate(options[:labe_date])
          xm.SenderName(options[:sender_name])
          xm.SenderEMail(options[:sender_email])
          xm.RecipientName(options[:recipient_name])
          xm.RecipientEMail(options[:recipient_email])
        end
      end
      builder.doc.root.to_xml
    end

    def parse_express_mail_label(xml, image_type)
      doc = Nokogiri::XML(xml)
      mime_type = image_mime_type image_type
      raise(USPSResponseError, doc.search('Description').inner_html) unless doc.xpath("Error").empty?
      label = doc.search("emLabel")
      postage = doc.search("postage")
      confirmation_number = doc.search("emConfirmationLabel").empty? ? "none" : doc.search("emConfirmationNumber")
      return {:image_type => mime_type, :confirmation_number => confirmation_number.inner_html, :postage => postage.inner_html, :label => label.inner_html}
    end

  end
end
