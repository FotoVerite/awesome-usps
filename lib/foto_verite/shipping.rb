module FotoVerite
  module Shipping

    MAX_RETRIES = 3

    ORIGIN_ZIP = "07024" #User should change this

    LIVE_DOMAIN = 'production.shippingapis.com'
    LIVE_RESOURCE = '/ShippingAPI.dll'

    TEST_DOMAINS = { #indexed by security; e.g. TEST_DOMAINS[USE_SSL[:rates]]
      true => 'secure.shippingapis.com',
      false => 'testing.shippingapis.com'
    }

    TEST_RESOURCE = '/ShippingAPITest.dll'

    API_CODES = {
      :us_rates => 'RateV3',
      :world_rates => 'IntlRate',
      :test => 'CarrierPickupAvailability'
    }

    USE_SSL = {
      :tracking => false,
      :test => true
    }
    CONTAINERS = {
      :envelope => 'Flat Rate Envelope',
      :box => 'Flat Rate Box'
    }
    MAIL_TYPES = {
      :package => 'Package',
      :postcard => 'Postcards or aerogrammes',
      :matter_for_the_blind => 'Matter for the blind',
      :envelope => 'Envelope'
    }
    PACKAGE_PROPERTIES = {
      'ZipOrigination' => :origin_zip,
      'ZipDestination' => :destination_zip,
      'Pounds' => :pounds,
      'Ounces' => :ounces,
      'Container' => :container,
      'Size' => :size,
      'Machinable' => :machinable,
      'Zone' => :zone,
      'Postage' => :postage,
      'Restrictions' => :restrictions
    }
    POSTAGE_PROPERTIES = {
      'MailService' => :service,
      'Rate' => :rate
    }
    US_SERVICES = {
      :first_class => 'FIRST CLASS',
      :priority => 'PRIORITY',
      :express => 'EXPRESS',
      :bpm => 'BPM',
      :parcel => 'PARCEL',
      :media => 'MEDIA',
      :library => 'LIBRARY',
      :all => 'ALL'
    }

    #Determins size of package automatically. Taken from Active_Shipping
    def size_code_for(package)
      total = package.inches(:length) + package.inches(:girth)
      if total <= 84
        return 'REGULAR'
      elsif total <= 108
        return 'LARGE'
      else # <= 130
        return 'OVERSIZE'
      end
    end

    # options Are?
    def domestic_rates(destination_zip, packages, options={})
      @packages = Array(packages)
      @destination_zip = destination_zip
      @options = options
      request = xml_for_us
      tracking_commit(:us_rates, request ,false)
    end

    # options Are?
    def world_rates(country, packages, options={})
      @packages = Array(packages)
      @country = country
      @options = options
      request = xml_for_world
      tracking_commit(:world_rates, request ,false)
    end

    # XML built with Build:XmlMarkup
    def xml_for_us
      xm = Builder::XmlMarkup.new
      xm.RateV3Request("USERID"=>"#{@username}") do
        @packages.each_index do |id|
          p = @packages[id]
          xm.Package("ID" => "#{id}") {
            xm.Service("#{US_SERVICES[@options[:service]] || :all}")
            xm.ZipOrigination(ORIGIN_ZIP)
            xm.ZipDestination(@destination_zip)
            xm.Pounds("0")
            xm.Ounces("#{'%0.1f' % [p.ounces,1].max}")
            if p.options[:container] and [nil,:all,:express,:priority].include? p.service
              xm.Container(CONTAINERS[p.options[:container]])
            end
            xm.Size(size_code_for(p))
            xm.Width(p.inches(:width))
            xm.Length(p.inches(:length))
            xm.Height(p.inches(:height))
            xm.Girth(p.inches(:girth))
            xm.Machinable((p.options[:machinable] ? true : false).to_s.upcase)
          }
        end
      end
    end

    # XML built with Build:XmlMarkup
    def xml_for_world
      xm = Builder::XmlMarkup.new
      xm.IntlRateRequest("USERID"=>"#{@username}") do
        @packages.each_index do |id|
          p = @packages[id]
          xm.Package("ID" => "#{id}") {
            xm.Pounds("0")
            xm.Ounces("#{'%0.1f' % [p.ounces,1].max.ceil}")
            xm.MailType("#{MAIL_TYPES[p.options[:mail_type]] || 'Package'}")
            xm.ValueOfContents(p.value / 100.0) if p.value && p.currency == 'USD'
            xm.Country(@country)
          }
        end
      end
    end


    # Returns the sent xml as a hash orgainzied by each package and service type.
    # example
    # {Package1 =>{'First Class' => "1.90"}Package2 => {'First Class' => "26.90" }

    def parse_us(xml)
      domestic_rate_hash = Hash.new
      i= 0
      Hpricot.parse(xml).search('package').each do |package|
        i+=1
        #This will return the first error description found in response xml.
        #TODO find way to return all errors.
        if package.search("error") != []
          RAILS_DEFAULT_LOGGER.info("package number #{i} has the error #{package.search("description").inner_html} please fix before continuing")

          return "package number #{i} has the error #{package.search("description").inner_html} please fix before continuing"
        end
        #Initializing hash for each package. Is there a better way I wonder.
        domestic_rate_hash["Package#{i}"] = {}
        #Going through each package and finding the rate.
        package.search("postage").each do |services|
          mailservice=services.search("mailservice")
          rate = services.search("rate")
          domestic_rate_hash["Package#{i}"][mailservice.inner_html] = rate.inner_html
        end
      end
      if domestic_rate_hash == {}
        domestic_rate_hash = Hpricot.parse(xml).search('description').inner_html
      end
      return domestic_rate_hash
    end

    # Returns the sent xml as a hash orgainzied by each package and service type.
    # example
    # {Package1 => {'Globle Express Mail' => "36.90"}Package2 => {'Globle Express Mail' => "26.90" }
    def parse_world(xml)
      international_rate_hash = Hash.new
      i= 0
      Hpricot.parse(xml).search('package').each do |package|
        i+=1
        #This will return the first error description found in response xml.
        #TODO find way to return all errors.
        if package.search("error") != []
          RAILS_DEFAULT_LOGGER.info("package number #{i} has the error #{package.search("description").inner_html} please fix before continuing")

          return "package number #{i} has the error #{package.search("description").inner_html} please fix before continuing"
        end
        #Initializing hash for each package. Is there a better way I wonder.
        international_rate_hash["Package#{i}"] = {}
        #Going through each package and finding the rate.
        package.search("service").each do |services|
          svcdescription=services.search("svcdescription")
          rate = services.search("postage")
          international_rate_hash["Package#{i}"][svcdescription.inner_html] = rate.inner_html
        end
      end
      if international_rate_hash == {}
        international_rate_hash = Hpricot.parse(xml).search('description').inner_html
      end
      return international_rate_hash
    end

    private
    def tracking_commit(action, request, test = false)
      retries = MAX_RETRIES
      begin
        url = URI.parse("http://#{LIVE_DOMAIN}#{LIVE_RESOURCE}")
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data({'API' => API_CODES[action], 'XML' => request})
        response = Net::HTTP.new(url.host, url.port)
        response.open_timeout = 5
        response.read_timeout = 5
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
      when Net::HTTPSuccess, Net::HTTPRedirection
        if (action == :us_rates)
          parse_us(response.body)
        else
          parse_world(response.body)
        end
      else
        RAILS_DEFAULT_LOGGER.warn("USPS plugin settings are wrong #{response}")
        return "USPS plugin settings are wrong #{response}"
      end
    end
  end
end

