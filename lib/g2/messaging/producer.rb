module Messaging
  class Producer
    class << self
      attr_accessor :debug_mode

      def async_pool
        prepare_cleanup
        @async_pool ||= ConnectionPool.new(size: config.pool, timeout: 5) do
          kafka_client.async_producer(
            delivery_threshold: config.delivery_threshold,
            delivery_interval: config.delivery_interval,
            max_queue_size: config.max_queue_size
          )
        end
      end

      def sync_pool
        prepare_cleanup
        @sync_pool ||= ConnectionPool.new(size: config.pool, timeout: 5) do
          kafka_client.producer
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
        trap('QUIT') { Messaging::Producer.shutdown }
        trap('INT') { Messaging::Producer.shutdown }
        trap('TERM') { Messaging::Producer.shutdown }
        @cleanup_prepared = true
      end

      def kafka_client
        Kafka.new(
          client_id: config.client_id,
          ssl_ca_cert: config.trusted_cert,
          ssl_client_cert: config.client_cert,
          ssl_client_cert_key: config.client_cert_key,
          seed_brokers: config.url,
          logger: Messaging::Logger.new(Rails.try(:logger))
        )
      end
    end
  end
end
