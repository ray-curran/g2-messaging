require 'ruby-kafka'
require 'connection_pool'

module Messaging
  class Consumer
    class << self
      def reset
        shutdown
        @pool = nil
        @cleanup_prepared = false
      end

      def pool
        prepare_cleanup
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
        trap(signal) { Messaging::Consumer.shutdown }
      end

      def kafka_client
        Kafka.new(
          client_id: config.prefix + config.client_id,
          ssl_ca_cert: config.trusted_cert,
          ssl_client_cert: config.client_cert,
          ssl_client_cert_key: config.client_cert_key,
          seed_brokers: config.url,
          connect_timeout: 30,
          socket_timeout: 15,
          logger: Messaging::Logger.new(config.logger)
        )
      end
    end
  end
end
