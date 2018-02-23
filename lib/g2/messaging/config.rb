require 'king_konf'

module Messaging
  class Config < KingKonf::Config
    env_prefix :messaging

    desc 'Comma separated list of kafka brokers'
    string :seed_brokers

    desc 'Kafka client id for this node'
    string :client_id

    desc 'Connection pool size'
    integer :pool

    desc 'Group and throttle prefix for kafka pools'
    string :prefix
    string :ssl_client_cert
    string :ssl_client_cert_key
    string :ssl_ca_cert
    string :ssl_ca_cert_file_path

    desc 'Message count throttle for async producers'
    integer :delivery_threshold, default: 100

    desc 'Time throttle for async producers'
    integer :delivery_interval,  default: 5

    desc '# of messages that can be queued up by producer'
    integer :max_queue_size, default: 5000
  end
end
