require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'

class Adaptor
  def getUsers(num)
    # リクエスト
    uri = URI.parse(ENV['api'] + '/user/' + "#{num}")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
    return JSON.parse(response.body)
  end
end