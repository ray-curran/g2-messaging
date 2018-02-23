require 'g2/messaging/version'
require 'g2/messaging/config'
require 'g2/messaging/consumer'
require 'g2/messaging/producer'
require 'g2/messaging/logger'

module Messaging
  def self.config
    @config ||= Messaging::Config.new
    yield @config if block_given?
    @config
  end
end
