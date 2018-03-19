require 'king_konf'

module Messaging
  class Config < KingKonf::Config
    attr_writer :error_reporter
    env_prefix :kafka

    desc 'Location of json-schema files'
    string :schema_path, default: File.join(File.dirname(__FILE__), '../../../schema')

    desc 'Comma separated list of kafka brokers'
    string :url, default: 'kafka:9092'

    desc 'Kafka client id for this node'
    string :client_id

    desc 'Connection pool size'
    integer :pool, default: 5

    desc 'Group and topic prefix for kafka'
    string :prefix, default: 'message-bus.'

    desc 'Message count throttle for async producers'
    integer :delivery_threshold, default: 100

    desc 'Time throttle for async producers'
    integer :delivery_interval,  default: 5

    desc 'Timeout for producer pool'
    integer :delivery_timeout,  default: 15

    desc '# of messages that can be queued up by producer'
    integer :max_queue_size, default: 5000

    desc 'Compression codec for producing messages'
    string :compression_codec, default: :gzip

    desc 'Seconds to wait on connection'
    integer :connection_timeout, default: 30

    desc 'Seconds to wait on socket, this is a long runner'
    integer :socket_timeout, default: 15

    desc 'Racecar seconds to wait on connection'
    integer :racecar_connect_timeout, default: 10

    desc 'Racecar seconds to wait on socket'
    integer :racecar_socket_timeout, default: 30

    string :client_cert
    string :client_cert_key
    string :trusted_cert

    def trusted_cert_file_path
      return unless trusted_cert
      return @file.path if @file

      @file = Tempfile.new('ca_certs')
      @file.write(trusted_cert)
      @file.close

      @file.path
    end

    def logger
      return Rails.logger if defined? Rails.logger
      @logger ||= Messaging::Logger.new
    end

    def error_reporter
      @error_reporter ||= lambda { |e| puts e }
    end
  end
end
