require 'connection_pool'
require 'g2/messaging'

module Messaging
  class Producer
    class << self
      attr_accessor :debug_mode

      def reset
        shutdown
        @async_pool = nil
        @sync_pool = nil
        @cleanup_prepared = false
      end

      def async_pool
        prepare_cleanup
        @async_pool ||= ConnectionPool.new(size: config.pool, timeout: config.delivery_timeout) do
          kafka_client.async_producer(
            delivery_threshold: config.delivery_threshold,
            delivery_interval: config.delivery_interval,
            compression_codec: config.compression_codec,
            max_queue_size: config.max_queue_size
          )
        end
      end

      def sync_pool
        prepare_cleanup
        @sync_pool ||= ConnectionPool.new(size: config.pool, timeout: config.delivery_timeout) do
          kafka_client.producer(compression_codec: config.compression_codec)
        end
      end

      def config
        Messaging.config
      end

      def with(&block)
        async_pool.with(&block)
      end

      def produce(value, topic:, key: nil)
        return if debug_mode
        async_pool.with do |c|
          c.produce value, topic: "#{config.prefix}#{topic}", key: key
        end
      end

      def produce!(value, topic:, key: nil)
        return if debug_mode
        sync_pool.with do |c|
          c.produce value, topic: "#{config.prefix}#{topic}", key: key
          c.deliver_messages
        end
      end

      def shutdown
        async_pool.shutdown { |producer| producer.shutdown }
        sync_pool.shutdown { |producer| producer.shutdown }
      end

      def prepare_cleanup
        return if @cleanup_prepared
        if RUBY_ENGINE == 'ruby'
          shut_your_trap('QUIT')
          shut_your_trap('TERM')
        end
        shut_your_trap('INT')
        @cleanup_prepared = true
      end

      def shut_your_trap(signal)
        trap(signal) { Messaging::Producer.shutdown }
      end

      def kafka_client
        Kafka.new(
          client_id: config.client_id,
          ssl_ca_cert: config.trusted_cert,
          ssl_client_cert: config.client_cert,
          ssl_client_cert_key: config.client_cert_key,
          seed_brokers: config.url,
          logger: Messaging::Logger.new(config.logger)
        )
      end
    end
  end
end
