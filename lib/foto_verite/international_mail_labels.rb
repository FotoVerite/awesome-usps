module  FotoVerite
  module InternationalMailLabels

    MAX_RETRIES = 3

    LIVE_DOMAIN = 'secure.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    def express_mail_international_label(sender, receiver, items, content_type, image_type, po_box_flag ="N",  request_api = "ExpressMailIntlRequest",
      image_layout="ALLINONEFILE", label_type="1", options={})
      Array(items) if not items.is_a? Array
      request = international_mail_labels_xml(request_api, sender, receiver, items, content_type, image_type, po_box_flag,
      image_layout, label_type, options)
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      gateway_commit(:express_mail, 'ExpressMailIntl', request, :ssl, image_type)
    end

    def canned_express_mail_international_label_test
      sender = Location.new( :first_name=> "John",  :last_name => "Berger", :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770', :phone => "2016585989")
      receiver =Location.new( :name=> "Fairfax Post Office",  :address2 =>"10660 Page Ave",   :city => 'Tokyo', :zip5 => "22030", :country => "Japan" )
      po_box_flag ="N"
      content_type = "GIFT"
      image_layout="ALLINONEFILE"
      image_type = "PDF"
      items = [InternationalItem.new(:ounces => 50, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00), InternationalItem.new(:ounces => 40, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00)]
      request_api = "ExpressMailIntlCertifyRequest"
      label_type="1"
      options ={}
      request= international_mail_labels_xml(request_api, sender, receiver, items, content_type, image_type, po_box_flag, image_layout, label_type, options)
      gateway_commit(:express_mail_certify, 'ExpressMailIntlCertify', request, :ssl, image_type)
    end
    
    def priority_mail_international_label(sender, receiver, items, content_type, image_type, po_box_flag ="N",
      image_layout="ALLINONEFILE", label_type="1", request_api = "PriorityMailIntlRequest", options={})
      Array(items) if not items.is_a? Array
      request = international_mail_labels_xml(request_api, sender, receiver, items, content_type, image_type, po_box_flag,
      image_layout, label_type, options)
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      gateway_commit(:priority_mail, 'PriorityMailIntl', request, :ssl, image_type)
    end

    def canned_priority_mail_international_label_test
      sender = Location.new( :first_name=> "John",  :last_name => "Berger", :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770', :phone => "2016585989")
      receiver =Location.new( :name=> "Fairfax Post Office",  :address2 =>"10660 Page Ave",   :city => 'Tokyo', :zip5 => "22030", :country => "Japan" )
      po_box_flag ="N"
      content_type = "GIFT"
      image_layout="ALLINONEFILE"
      image_type = "PDF"
      items = [InternationalItem.new(:ounces => 50, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00), InternationalItem.new(:ounces => 40, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00)]
      request_api = "PriorityMailIntlCertifyRequest"
      label_type="1"
      options ={}
      request= international_mail_labels_xml(request_api, sender, receiver, items, content_type, image_type, po_box_flag,
      image_layout, label_type, options)
      gateway_commit(:priority_mail_certify, 'PriorityMailIntlCertify', request, :ssl, image_type)
    end

    def first_class_international_label(sender, receiver, items, content_type, image_type, po_box_flag ="N",
      image_layout="ALLINONEFILE", label_type="1", request_api = "FirstClassMailIntlRequest", options={})
      Array(items) if not items.is_a? Array
      request = first_class_international_mail_labels_xml(request_api, sender, receiver, items, content_type, image_type, po_box_flag,
      image_layout, label_type, options)
      #YES THE API IS THAT STUPID THAT WE MUST PASS WHAT TYPE OF MIME TYPE!
      gateway_commit(:first_class_mail, 'FirstClassMailIntl', request, :ssl, image_type)
    end

    def canned_first_class_mail_international_label_test
      sender = Location.new( :first_name=> "John",  :last_name => "Berger", :address2 => "6406 Ivy Lane",  :state => 'MD', :city => 'Greenbelt', :zip5 => '20770', :phone => "2016585989")
      receiver =Location.new( :name=> "Fairfax Post Office",  :address2 =>"10660 Page Ave",   :city => 'Tokyo', :zip5 => "22030", :country => "Japan" )

      po_box_flag ="N"
      content_type = "GIFT"
      image_layout="ALLINONEFILE"
      image_type = "PDF"
      items = [InternationalItem.new(:ounces => 10, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00), InternationalItem.new(:ounces => 10, :country => "United States", :quantity => "50", :description => "Pens Pens Pens", :value => 50.00)]
      request_api = "FirstClassMailIntlCertifyRequest"
      label_type="1"
      options ={}
      request= first_class_international_mail_labels_xml(request_api, sender, receiver, items, content_type, image_type, po_box_flag,
      image_layout, label_type, options)
      gateway_commit(:first_class_mail_certify, 'FirstClassMailIntlCertify', request, :ssl, image_type)
    end

    private
    def international_mail_labels_xml(request_api, sender, receiver, items, content_type, image_type, po_box_flag,
    image_layout, label_type, options)
      xm = Builder::XmlMarkup.new
      xm.tag!("#{request_api}", "USERID"=>"#{@username}") do
        xm.Option
        xm.ImageParameters
        xm.FromFirstName(sender.first_name)
        xm.FromMiddleInitial(options[:middle_initial])
        xm.FromLastName(sender.last_name)
        xm.FromFirm(sender.firm_name)
        xm.FromAddress1(sender.address1)
        xm.FromAddress2(sender.address2)
        xm.FromUrbanization(sender.from_urbanization)
        xm.FromCity(sender.city)
        xm.FromState(sender.state)
        xm.FromZip5(sender.zip5)
        xm.FromZip4(sender.zip4)
        xm.FromPhone(sender.phone)
        xm.FromCustomsReference(options[:from_customs_reference])
        xm.ToName(receiver.name)
        xm.ToFirm(receiver.firm_name)
        xm.ToAddress1(receiver.address1)
        xm.ToAddress2(receiver.address2)
        xm.ToAddress3(receiver.address3)
        xm.ToCity(receiver.city)
        xm.ToProvince(receiver.province)
        xm.ToCountry(receiver.country)
        xm.ToPostalCode(receiver.postal_code)
        xm.ToPOBoxFlag(po_box_flag)
        xm.ToPhone(receiver.phone)
        xm.ToFax(options[:fax])
        xm.ToEmail(options[:email])
        xm.ToCustomsReference(options[:to_customs_reference])
        xm.NonDeliveryOption(options[:non_delivery_option])
        xm.AltReturnAddress1(options[:alt_return_address1])
        xm.AltReturnAddress2(options[:alt_return_address2])
        xm.AltReturnAddress3(options[:alt_return_address3])
        xm.AltReturnCountry(options[:alt_return_country])
        xm.Container(options[:container])
        xm.ShippingContents do
          items.each do |item|
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
        xm.InsuredNumber(options[:insurance_number])
        xm.InsuredAmount(options[:insured_amount])
        xm.Postage(options[:postage])
        xm.GrossPounds("0")
        xm.GrossOunces(items.sum {|item| item.ounces.to_f})
        xm.ContentType(content_type)
        xm.ContentTypeOther(options[:other])
        xm.Agreement("Y")
        xm.Comments(options[:comments])
        xm.LicenseNumber(options[:license_number])
        xm.CertificateNumber(options[:certificate_number])
        xm.InvoiceNumber(options[:invoice_number])
        xm.ImageType(image_type)
        xm.ImageLayout(image_layout)
        xm.CustomerRefNo(options[:reference_number])
        xm.POZipCode(options[:po_zip_code])
        xm.LabelDate(options[:label_date])
        xm.HoldForManifest(options[:hold])
      end
    end

    def first_class_international_mail_labels_xml(request_api, sender, receiver, items, content_type, image_type, po_box_flag,
    image_layout, label_type, options)
      xm = Builder::XmlMarkup.new
      xm.tag!("#{request_api}", "USERID"=>"#{@username}") do
        xm.Option
        xm.ImageParameters
        xm.FromFirstName(sender.first_name)
        xm.FromMiddleInitial(options[:middle_initial])
        xm.FromLastName(sender.last_name)
        xm.FromFirm(sender.firm_name)
        xm.FromAddress1(sender.address1)
        xm.FromAddress2(sender.address2)
        xm.FromUrbanization(sender.from_urbanization)
        xm.FromCity(sender.city)
        xm.FromState(sender.state)
        xm.FromZip5(sender.zip5)
        xm.FromZip4(sender.zip4)
        xm.FromPhone(sender.phone)
        xm.ToName(receiver.name)
        xm.ToFirm(receiver.firm_name)
        xm.ToAddress1(receiver.address1)
        xm.ToAddress2(receiver.address2)
        xm.ToAddress3(receiver.address3)
        xm.ToCity(receiver.city)
        xm.ToProvince(receiver.province)
        xm.ToCountry(receiver.country)
        xm.ToPostalCode(receiver.postal_code)
        xm.ToPOBoxFlag(po_box_flag)
        xm.ToPhone(receiver.phone)
        xm.ToFax(options[:fax])
        xm.ToEmail(options[:email])
        xm.FirstClassMailType(options[:first_class_mail_type])
        xm.ShippingContents do
          items.each do |item|
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
        xm.GrossOunces(items.sum {|item| item.ounces.to_f})
        xm.Machinable(options[:machinable])
        xm.ContentType(content_type)
        xm.ContentTypeOther(options[:other])
        xm.Agreement("Y")
        xm.Comments(options[:comments])
        xm.ImageType(image_type)
        xm.ImageLayout(image_layout)
        xm.LabelDate(options[:label_date])
        xm.HoldForManifest(options[:hold])
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

  end
end
