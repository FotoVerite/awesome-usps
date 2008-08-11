module ForteDesigns
  class Request < USPS
    def commit(action, request, test = false)
      http = Net::HTTP.new((test ? TEST_DOMAINS[USE_SSL[action]] : LIVE_DOMAIN),
      (USE_SSL[action] ? 443 : 80 ))
      http.use_ssl = USE_SSL[action]
      response = http.start do |http|
        http.get "#{test ? TEST_RESOURCE : LIVE_RESOURCE}?API=#{API_CODES[action]}&XML=#{request}"
      end
      response.body
    end
  end
end
