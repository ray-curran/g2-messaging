require 'g2/messaging/version'
require 'g2/messaging/config'
require 'g2/messaging/consumer'
require 'g2/messaging/racecar_consumer'
require 'g2/messaging/bad_data_error'
require 'g2/messaging/producer'
require 'g2/messaging/logger'
require 'g2/messaging/active_record'

module Messaging
  def self.config
    @config ||= Messaging::Config.new
  end

  def self.configure
    yield config
  end

  def self.start_racecar!
    require 'racecar'

    c = config

    Racecar.configure do |conf|
      conf.client_id = c.prefix + c.client_id
      conf.group_id_prefix = c.prefix
      conf.brokers = c.url.split(',')
      conf.ssl_client_cert = c.client_cert
      conf.ssl_client_cert_key = c.client_cert_key
      conf.ssl_ca_cert_file_path = c.trusted_cert_file_path
    end
  end
end
