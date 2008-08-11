# Awesome USPS

This library is meant to interface with the web services of USPS. It grew out of early dabbling of the USPS_Tracker plugin. The goal is to abstract the features that are most frequently used into a pleasant and consistent Ruby API. Awesome USPS started as an extension of Active Shipping but at the moment I am still struggling with how best to accomplish integration. While working on the problem I decided to release my current work as a separate plugin for all to enjoy. Next up the Awesome USPS gem.

[Matthew Bergman]:http://matthewbergman.com
[discuss]:http://groups.google.com/group/Awsome-USPS
[Active Shipping]:http://github.com/Shopify/active_shipping/tree/master



## Prerequisites

* [Hrpicot](http://code.whytheluckystiff.net/hpricot/) for parsing the XML. To install run sudo gem install Hpricot
* [mocha](http://mocha.rubyforge.org/) for the tests

## Download & Installation

Currently this library is available on GitHub:

  <http://github.com/ForteDesigns/awesome_usps>

You will need to get [Git][] if you don't have it. Then:

  > script/plugin install  git://github.com/ForteDesigns/awesome_usps.git

 if using rails prior to 2.1:

  > git clone git://github.com/ForteDesigns/awesome_usps.git

(That URL is case-sensitive, so watch out.)
  
Awesome USPS includes an init.rb file. This means that Rails will automatically load it on startup. Check out [git-archive][] for exporting the file tree from your repository to your vendor directory.

Gem and tarball forthcoming on rubyforge.
  
[Git]:http://git.or.cz/
[git-archive]:http://www.kernel.org/pub/software/scm/git/docs/git-archive.html

## Notice about using the USPS API
 USPS can be a bit frustrating when starting working with them. First you must apply for a USPS web tools account
[USPS Web Tools]:https://secure.shippingapis.com/registration/

This will net you a USPS user name assigned by them and a password. The password is for older versions of their api so you do not need to concern yourself with it. 

Secondly you only have accesses to the Testing Server. You should run the canned responses to make sure everything is setup up correctly. 
	
	USPS.canned_tracking
	
	or
	
	USPS.canned_us_shipping

You should get the response "Everything is Working"

From there you need to email USPS for your account to be changed over to production. 

	#TODO Explain what must be done for Labels API

## Sample Usage
	#In your environment.rb or production.rb
	
    require 'active_shipping'
    include ForteDesigns::AwesomeUsps

	# Then to access the plugin you much create an instance of USPS class
	 USPS = USPS.new('Your user name')
	
  
    # Package up a poster and a Wii for your nephew.
	# Note the Package Module has been taken directly from Active Shipping. Thank you James MacAulay for developing such great code. 
    packages = [
      Package.new(  100,                        # 100 grams
                    [93,10],                    # 93 cm long, 10 cm diameter
                    :cylinder => true),         # cylinders have different volume calculations
    
      Package.new(  (7.5 * 16),                 # 7.5 lbs, times 16 oz/lb.
                    [15, 10, 4.5],              # 15x10x4.5 inches
                    :units => :imperial)        # not grams, not centimetres
    ]
  
  
#To track a package

	USPS.track("Number")
	
	#This will return an array of tracking events example shown below
	
	[{:eventzipcode=>"33436", :event=>"Arrival at Unit", :eventtime=>"7:23 am", :eventdate=>"June 14, 2008", :eventcity=>"BOYNTON BEACH", :eventstate=>"FL"},
	 {:eventzipcode=>"32862", :event=>"Processed", :eventtime=>"9:50 pm", :eventdate=>"June 13, 2008", :eventcity=>"ORLANDO", 	:eventstate=>"FL"},
	 {:eventzipcode=>"07032", :event=>"Processed", :eventtime=>"1:19 am", :eventdate=>"June 13, 2008", :eventcity=>"KEARNY", 	:eventstate=>"NJ"},
	 {:eventzipcode=>"07024", :event=>"Acceptance", :eventtime=>"3:03 pm", :eventdate=>"June 12, 2008", :eventcity=>"FORT LEE", :eventstate=>"NJ"}]
	
	#Loop through and display as you wish
	
#To get rates for a single or group of packages. 

	# Package up a poster and a Wii for your nephew.
	# Note the Package Module has been taken directly from Active Shipping. Thank you James MacAulay for developing such great code. 
	packages = [
  	  Package.new(  100,                        # 100 grams
                    [93,10],                    # 93 cm long, 10 cm diameter
                	:cylinder => true),         # cylinders have different volume calculations

  	  Package.new(  (7.5 * 16),                 # 7.5 lbs, times 16 oz/lb.
                	[15, 10, 4.5],              # 15x10x4.5 inches
                	:units => :imperial)        # not grams, not centimetres
	  ]
	
 	#Then user either the domestic rates or world rates method

	USPS.domestic_rates(ZIP, Packages, options={})
	USPS.world_rates(Country, Packages, options={})
	
	#Both will return a hash organized by Package and service
	
	{"Package1"=>{"Priority Mail International Flat-Rate Box"=>"38.95", "USPS GXG Envelopes"=>"97.00", "Priority Mail International Large Flat-Rate
	 Box"=>"49.95", "Priority Mail International"=>"48.00", "Express Mail International (EMS) Flat-Rate Envelope"=>"25.95", "Express Mail International
	 (EMS)"=>"55.50", "Global Express Guaranteed Non-Document Non-Rectangular"=>"97.00", "Global Express Guaranteed Non-Document Rectangular"=>"97.00",
	 "Global Express Guaranteed"=>"97.00"}, "Package2"=>{"Priority Mail International Flat-Rate Box"=>"38.95", "USPS GXG Envelopes"=>"148.00", 
	 "Priority Mail International Large Flat-Rate Box"=>"49.95", "Priority Mail International"=>"81.75", "Express Mail International (EMS) Flat-Rate
	 Envelope"=>"25.95", "Express Mail International (EMS)"=>"100.50", "Global Express Guaranteed Non-Document Non-Rectangular"=>"148.00", "Global Express
	 Guaranteed Non-Document Rectangular"=>"148.00", "Global Express Guaranteed"=>"148.00"}}
	
	#To access a rate hash for use you can do 
	
	hash = 	USPS.world_rates(Country, Packages, options={})
	hash[Package1][Priority Mail International]
	
	#You can also loop through and sort

## TODO

* proper documentation
* package into a gem
* carrier code template generator
* label printing
* Add tests with RSPEC

## Contributing

Yes, please! I am a young Ruby Developer who is making plenty mistakes. Any improvements to the coding structure or patches would be highly appreciated. 

The nicest way to submit changes would be to set up a GitHub account and fork this project, then initiate a pull request when you want your changes looked at. You can also make a patch (preferably with [git-diff][]) and email to fortedesigns@gmail.com

[git-diff]:http://www.kernel.org/pub/software/scm/git/docs/git-diff.html



## Legal Mumbo Jumbo

Unless otherwise noted in specific files, all code in the Active Shipping project is under the copyright and license described in the included MIT-LICENSE file.

Packages Module created by James MacAulay