module Messaging
  class Consumer
    class << self
      def pool
        @pool ||= ConnectionPool.new(size: config.pool, timeout: 30) do
          kafka_client.consumer(group_id: "#{config.prefix}log-processor")
        end
      end

      def config
        Messaging.config
      end

      def with(&block)
        pool.with(&block)
      end

      def subscribe(topic, &block)
        with do |c|
          c.subscribe("#{config.prefix}#{topic}", start_from_beginning: true)
          c.each_message(max_wait_time: 5, min_bytes: 1024 * 1, &block)
        end
      end

      def shutdown
        pool.shutdown { |consumer| consumer.stop }
      end

      private

      def kafka_client
        Kafka.new(
          client_id: config.prefix + config.client_id,
          ssl_ca_cert_file_path: config.ssl_ca_cert_file_path,
          ssl_client_cert: config.ssl_client_cert,
          ssl_client_cert_key: config.ssl_client_cert_key,
          seed_brokers: config.seed_brokers,
          connect_timeout: 30,
          socket_timeout: 15,
          logger: Messaging::Logger.new(Rails.try(:logger))
        )
      end
    end
  end
end
