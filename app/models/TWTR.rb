class TWTR < ApplicationRecord
  def url_encode(s) #encode function I found online to properly encode the next param w/ the twitter API
     s.to_s.dup.force_encoding("ASCII-8BIT").gsub(/[^a-zA-Z0-9_\-.]/) {
       sprintf("%%%02X", $&.unpack("C")[0])
     }
   end
  def self.getTweets
    next_params = ""
    frontend_array = []
    while true
      res = RestClient::Request.execute(method: :get,
        url: "https://api.twitter.com/1.1/tweets/search/30day/dev.json?query=%23dctech has:media#{next_params}",
        :headers => {
          :Authorization => "Bearer #{ENV['BEARER']}"
          })
      next_response = url_encode(JSON.parse(res)['next'])
      break if (!next_response || next_response.nil? || next_response == "" || next_response == "next")
      #I am running out of api calls, so I this will do^
      next_params = "&next=#{next_response}"
      results = JSON.parse(res)['results']
      results.map! do |tweet| #pass data how we want in frontend
        {text: tweet["text"], name: tweet["user"]["screen_name"], count: tweet["retweet_count"]}
      end
      frontend_array.concat(results)
    end
  frontend_array.uniq! #removes duplicates as the twitter documentation warns that duplicates occur
end
end
