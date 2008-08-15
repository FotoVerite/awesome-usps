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

  <http://github.com/FotoVerite/awesome_usps>

You will need to get [Git][] if you don't have it. Then:

  > script/plugin install  git://github.com/FotoVerite/awesome_usps.git

 if using rails prior to 2.1:

  > git clone git://github.com/FotoVerite/awesome_usps.git

(That URL is case-sensitive, so watch out.)
  
Awesome USPS includes an init.rb file. This means that Rails will automatically load it on startup. Check out [git-archive][] for exporting the file tree from your repository to your vendor directory.

Gem and tarball forthcoming on rubyforge.
  
[Git]:http://git.or.cz/
[git-archive]:http://www.kernel.org/pub/software/scm/git/docs/git-archive.html

## Notice about using the USPS APIs
 USPS can be a bit frustrating when starting working with them. First you must apply for a USPS web tools account
[USPS Web Tools]:https://secure.shippingapis.com/registration/

This will net you a USPS user name assigned by them and a password. The password is for older versions of their api so you do not need to concern yourself with it. 

Secondly you only have accesses to the Testing Server. You should run one of the canned response to make sure everything is setup up correctly. 
	
	usps.canned_tracking

You should receive an array as a response. 

From there you need to email USPS for your account to be changed over to production so you can send live data. This does not hold true for all their Api some of which require and additional level of clearance. See Below

## Notice on USPS Label APIs

 USPS is kinda... bad with how they handle their various label creation APIs. Except for their Priority Mail® Open and Distribute API you must make an additional email or call to their customer care center to have your permission turned on to send live data to the server. It is even more complicated if you wish to create your own labels with your company logo from their response xml. See their API documentation located at
[http://www.http://www.usps.com/webtools/htm/Delivery-Confirmation.htm]:http://www.usps.com/webtools/htm/Delivery-Confirmation.htm for details on the procedure.

## Notice on Address Information APIs
These APIs; Specifically Address Verify, Zip Lookup, and City State Lookup also need separate permission for use of live data. 

## Canned Tests
Because most of the API's require an additional level of permission to use with live data every method has a canned test. They are both useful for integrating the returned data with your system and for testing that the library has not been compromised. A canned method follow this format. canned\_method\_name\_test. 
 
## Awesome USPS methods

API methods are as follow

* track
* veryify_address
* zip_lookup
* city\_state\_lookup
* delivery\_confirmation\_label
* signature\_confirmation\_label
* merch_return
* express_mail
* express\_mail\_international\_label
* priority\_mail\_international\_label
* first\_class\_international\_label
* open\_distrubute\_priority\_label
* priority\_mail\_estimated\_time
* standard\_mail\_estimated\_time
* domestic_rates
* world_rates

Object Methods are as follow

* Package.new
* Location.new
* International Location #Only used in conjunction with international labels API

## Sample Usage
	#In your environment.rb or production.rb
	
    require 'active_shipping'
    include FotoVerite::AwesomeUsps

	# Then to access the plugin you much create an instance of USPS class
	 usps = USPS.new('Your user name')
	
  
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

	USPS.track("Tracking Number")
	
	#This will return an array of tracking events example shown below
	
	[{:eventzipcode=>"33436", :event=>"Arrival at Unit", :eventtime=>"7:23 am", :eventdate=>"June 14, 2008",
	 :eventcity=>"BOYNTON BEACH", :eventstate=>"FL"},
	 {:eventzipcode=>"32862", :event=>"Processed", :eventtime=>"9:50 pm", 
	 :eventdate=>"June 13, 2008", :eventcity=>"ORLANDO", 	:eventstate=>"FL"},
	 {:eventzipcode=>"07032", :event=>"Processed", :eventtime=>"1:19 am",
	 :eventdate=>"June 13, 2008", :eventcity=>"KEARNY", 	:eventstate=>"NJ"},
	 {:eventzipcode=>"07024", :event=>"Acceptance", :eventtime=>"3:03 pm", :eventdate=>"June 12, 
	 2008", :eventcity=>"FORT LEE", :eventstate=>"NJ"}]
	
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
	
	#Both will return and array containg a hash of rates for each package.
	
	#To access a rate hash for use you can do 
	
	hash = 	USPS.world_rates(Country, Packages, options={})
	hash[0][Priority Mail International]
	
	#You can also loop through and sort

#Address Verification

	#All methods here will take a location array of up to five address
	
	#To verify an address and fill in missing information. If mulitple addresses were found for an address :verified => false
    usps.veryify_address("locations array")
	
	#Will fill in missing zip5 and zip4 for an address
	usps.zipcode_lookup("location array")
	
	#Will fill in missing City and State for an address
	usps.city_state_lookup


#
## TODO

* Better documentation
* package into a gem
* Add tests with RSPEC

## Contributing

Yes, please! I am a young Ruby Developer who is making plenty mistakes. Any improvements to the coding structure or patches would be highly appreciated. 

The nicest way to submit changes would be to set up a GitHub account and fork this project, then initiate a pull request when you want your changes looked at. You can also make a patch (preferably with [git-diff][]) and email to FotoVerite@gmail.com

[git-diff]:http://www.kernel.org/pub/software/scm/git/docs/git-diff.html



## Legal Mumbo Jumbo

Unless otherwise noted in specific files, all code in the Active Shipping project is under the copyright and license described in the included MIT-LICENSE file.

Packages Module created by James MacAulay

Copyright (c) 2008 FotoVerite, released under the MIT license
