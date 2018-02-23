module Messaging
  class Producer
    class << self
      attr_accessor :debug_mode

      def async_pool
        @async_pool ||= ConnectionPool.new(size: config.pool, timeout: 5) do
          kafka_client.async_producer(
            delivery_threshold: config.delivery_threshold,
            delivery_interval: config.delivery_interval,
            max_queue_size: config.max_queue_size
          )
        end
      end

      def sync_pool
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

      private

      def kafka_client
        Kafka.new(
          client_id: config.client_id,
          ssl_ca_cert: config.ssl_ca_cert,
          ssl_client_cert: config.ssl_client_cert,
          ssl_client_cert_key: config.ssl_client_cert_key,
          seed_brokers: config.seed_brokers,
          logger: Messaging::Logger.new(Rails.try(:logger))
        )
      end
    end
  end
end
