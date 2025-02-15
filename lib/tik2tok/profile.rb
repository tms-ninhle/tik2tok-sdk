require "httparty"
require "json"

module Tik2tok
  class Profile
    def initialize(token, columns: [], scopes: [])
      @token   = token
      @columns = columns
      @scopes  = scopes
      token_validate!
    end

    def get
      HTTParty.get(profile_url, headers: headers)
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
      return columns_by_scope(:all) if !@columns.nil? && !@columns.empty? && (@columns.is_a?(String) || @columns.is_a?(Symbol)) && ['all', :all].include?(@columns)
      return @columns if !@columns.nil? && !@columns.empty? && @columns.is_a?(String)
      return @columns.join(', ') if !@columns.nil? && !@columns.empty? && @columns.is_a?(Array)

      return basic_columns.join(', ') if @scopes.nil? || @scopes.empty?
      return columns_by_scope(:all) if !@scopes.nil? && !@scopes.empty? && (@scopes.is_a?(String) || @scopes.is_a?(Symbol)) && ['all', :all].include?(@scopes)
      return @scopes.split(',').map { |scope| columns_by_scope(scope) }.join(', ') if @scopes.is_a?(String)
      return @scopes.map { |scope| columns_by_scope(scope) }.join(', ') if @scopes.is_a?(Array)

      basic_columns.join(', ')
    end

    def columns_by_scope(scope)
      case scope
      when 'all', :all
        [basic_columns.join(', '), profile_columns.join(', '), stat_columns.join(', ')].join(', ')
      when 'basic', :basic, 'user.info.basic'
        basic_columns.join(', ')
      when 'profile', :profile, 'user.info.profile'
        profile_columns.join(', ')
      when 'stats', :stats, 'user.info.stats'
        stat_columns.join(', ')
      else
        basic_columns.join(', ')
      end
    end

    def basic_columns
      %w(open_id union_id avatar_url avatar_url_100 avatar_large_url display_name)
    end

    def profile_columns
      %w(bio_description profile_deep_link is_verified username)
    end

    def stat_columns
      %w(follower_count following_count likes_count video_count)
    end

		def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@token}"
      }
    end

    def profile_url
      "https://open.tiktokapis.com/v2/user/info/?fields=#{fields}"
    end
  end
end