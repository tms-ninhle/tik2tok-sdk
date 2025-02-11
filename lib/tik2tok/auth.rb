require "httparty"
require "json"

module Tik2tok
  class Auth
    def initialize(config)
      @config = config
    end

    def authorize
			uri = URI(config.authorize_url)
			uri.query = URI.encode_www_form(config.authorize_params)
			uri.to_s
    end

    def access_token(code: nil)
			HTTParty.post(config.authorize_token_url, body: config.authorize_token_params(code: code), headers: headers)
    rescue JSON::ParserError => e
      raise "Invalid JSON response: #{e.message}"
    rescue StandardError => e
      raise "Request failed: #{e.message}"
    end

    def refresh_token(refresh_token: nil)
			HTTParty.post(config.authorize_token_url, body: config.authorize_refresh_token_params(refresh_token: refresh_token), headers: headers)
    rescue JSON::ParserError => e
      raise "Invalid JSON response: #{e.message}"
    rescue StandardError => e
      raise "Request failed: #{e.message}"
    end

    def headers
      {
        "Content-Type" => "application/x-www-form-urlencoded",
        "Cache-Control" => "no-cache"
      }
    end

    private

    attr_reader :config

    def authorize_url
      @config.authorize_url + "?" + URI.encode_www_form(@config.authorize_params)
    end
  end
end