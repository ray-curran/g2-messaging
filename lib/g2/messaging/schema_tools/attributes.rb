module SchemaTools
  module Modules
    module Attributes
      def deliver_now(topic:, key: nil)
        Messaging::Deliver.perform_now(self, topic: topic, key: key)
      end

      def deliver_later(topic:, key: nil)
        Messaging::Deliver.perform_later(self, topic: topic, key: key)
      end
    end
  end
end
