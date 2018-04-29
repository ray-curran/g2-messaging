require 'racecar'

module Messaging
  class BaseConsumer < Racecar::Consumer
    class << self
      attr_accessor :backend

      def subscribes_to(*topics, start_from_beginning: true, max_bytes_per_partition: 1 * 1024 * 1024)
        prefixed_topics = topics.map { |i| "#{Messaging.config.prefix}#{i}" }
        super *prefixed_topics, start_from_beginning: start_from_beginning, max_bytes_per_partition: max_bytes_per_partition
      end

      def controller(klass)
        self.backend = klass
      end

      def backend
        @backend ||= Messaging::Backends::Inline
      end
    end

    def process(raw)
      backend.perform_later(raw.value, raw.key)
    rescue Encoding::UndefinedConversionError => e
      puts raw.value
      puts raw.value.encoding
      Messaging.config.error_reporter.call(e)
    rescue => e
      puts raw.value
      puts raw.key
      Messaging.config.error_reporter.call(e)
      raise e
    end

    private

    def backend
      self.class.backend
    end
  end
end
