module Messaging
  module Backends
    module Controller
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        attr_writer :handlers

        def handlers
          @handlers ||= {}
        end

        def handle(klass, &block)
          handlers[klass] = block
        end
      end

      def perform(value, key)
        attrs = JSON.parse(value)
        fail Messaging::ValidationError unless attrs.key?('schema_model') && attrs.key?('data')

        message = route(attrs)
        instance_exec(message, &handlers[message.class]) if message && handlers[message.class]

        config.logger.info "Processed #{key}"
      rescue JSON::ParserError => e
        config.error_reporter.call(e)
      rescue Messaging::ValidationError => e
        config.error_reporter.call(e)
      end

      private

      def handlers
        self.class.handlers
      end

      def config
        Messaging.config
      end

      def route(attrs)
        klass_name = attrs['schema_model'].classify
        return unless Object.const_defined? klass_name
        klass_name.constantize.new(attrs['data'])
      end
    end
  end
end
