# frozen_string_literal: true

require_relative "tik2tok/version"
require_relative "tik2tok/config"
require_relative "tik2tok/auth"

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
end
