# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'open-uri'

# Dangerous plugin with network access - FOR TESTING ONLY
module NetworkAccessPlugin
  include NumberAnalyzer::StatisticsPlugin

  plugin_name 'network_access'
  plugin_version '1.0.0'
  plugin_description 'Network access plugin'
  plugin_author 'Network Developer'

  def fetch_data
    # These should trigger network access warnings
    Net::HTTP.get(URI('http://example.com'))
    URI.open('http://example.com').read
    TCPSocket.new('example.com', 80)
    UDPSocket.new.send('data', 0, 'example.com', 53)
  end
end
