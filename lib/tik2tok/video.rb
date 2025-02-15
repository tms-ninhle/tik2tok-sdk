require "httparty"
require "json"

module Tik2tok
  class Video
    def initialize(token, columns: [])
      @token   = token
      @columns = columns
      token_validate!
      puts all_columns
    end

    def list(payload = { max_count: 20 })
      HTTParty.post(video_url, body: payload.to_json, headers: headers)
    rescue JSON::ParserError => e
      raise "Invalid JSON response: #{e.message}"
    rescue StandardError => e
      raise "Request failed: #{e.message}"
    end

    private

    def token_validate!
      raise "Access Token does not exists. Please config Access Token" if @token.nil? || @token.empty?
    end

    def fields
      return all_columns if !@columns.nil? && !@columns.empty? && (@columns.is_a?(String) || @columns.is_a?(Symbol)) && ['all', :all].include?(@columns)
      return @columns if !@columns.nil? && !@columns.empty? && @columns.is_a?(String)
      return @columns.join(", ") if !@columns.nil? && !@columns.empty? && @columns.is_a?(Array)

      all_columns
    end

    def all_columns
      %w(
        id create_time cover_image_url share_url video_description duration
        height width title embed_html embed_link like_count comment_count share_count view_count
      ).join(', ')
    end

		def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@token}"
      }
    end

    def video_url
      "https://open.tiktokapis.com/v2/video/list/?fields=#{fields}"
    end
  end
end
