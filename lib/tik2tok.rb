# frozen_string_literal: true

require_relative "tik2tok/version"
require_relative "tik2tok/config"
require_relative "tik2tok/auth"
require_relative "tik2tok/profile"
require_relative "tik2tok/video"

module Tik2tok
  class Error < StandardError; end
  # Your code goes here...

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config) if block_given?
  end

  def self.auth
    @auth ||= Auth.new(config)
  end

  def self.profile(token, columns: [], scopes: [])
    @profile ||= Profile.new(token, columns: columns, scopes: scopes).get
  end

  def self.video(token)
    @video ||= Video.new(token)
  end
end
