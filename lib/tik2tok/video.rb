require "httparty"
require "json"
require "uri"
require "mime/types"

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

    def publish(source, caption = nil)
      post_info = { privacy_level: "PUBLIC_TO_EVERYONE" }
      post_info[:title] = caption if caption

      if is_url?(source)
        handle_publish_video_from_url(source, post_info)
      elsif is_path?(source)
        handle_publish_video_from_local(source, post_info)
      else
        raise "Video not found. Video is `video url` or `path to video`"
      end
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

    def handle_publish_video_from_url(source, post_info = {})
      payload = {
        post_info: post_info,
        source_info: {
          source: "PULL_FROM_URL",
          video_url: source
        }
      }

      HTTParty.post(video_publish_url, body: payload.to_json, headers: headers)
    rescue JSON::ParserError => e
      raise "Invalid JSON response: #{e.message}"
    rescue StandardError => e
      raise "Request failed: #{e.message}"
    end

    def handle_publish_video_from_local(source, post_info = {})
      content_type = get_content_type(source)

      raise "Unable to determine content type for file: #{source}" if content_type.nil? || content_type.empty?
      raise "Content type '#{content_type}' is not supported." if is_supported_video?(content_type)

      min_chunk_size = 5 * 1024 * 1024
      max_chunk_size = 64 * 1024 * 1024

      video_size = File.size(source)

      chunk_size = [video_size, max_chunk_size].min
      chunk_size = video_size if chunk_size < min_chunk_size
      total_chunk_count = (video_size.to_f / chunk_size).ceil
      payload = {
        post_info: post_info,
        source_info: {
          source: "FILE_UPLOAD",
          video_size: video_size,
          chunk_size: chunk_size,
          total_chunk_count: total_chunk_count
        }
      }
      puts payload.inspect
      response = HTTParty.post(video_publish_url, body: payload.to_json, headers: headers)

      return response unless response.success?

      video_publish_id = response.dig("data", "publish_id")
      video_upload_url = response.dig("data", "upload_url")

      upload_video_headers = headers.merge({
        "Content-Range" => "bytes 0-#{video_size - 1}/#{video_size}",
        "Content-Length" => video_size.to_s,
        "Content-Type" => content_type
      })

      video_source = File.open(source, "rb") { |file| file.read }
      HTTParty.put(video_upload_url, headers: upload_video_headers, body: video_source)
    rescue JSON::ParserError => e
      raise "Invalid JSON response: #{e.message}"
    rescue StandardError => e
      raise "Request failed: #{e.message}"
    end

    def video_publish_url
      "https://open.tiktokapis.com/v2/post/publish/inbox/video/init/"
    end

    def is_url?(input)
      uri = URI.parse(input)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end

    def is_path?(input)
      File.exist?(input)
    end

    def get_content_type(source)
      mime_type = MIME::Types.type_for(source).first
      mime_type ? mime_type.content_type : nil
    end

    def is_supported_video?(content_type)
      supported_types = ["video/mp4", "video/quicktime", "video/webm"]
      supported_types.include?(content_type)
    end
  end
end
