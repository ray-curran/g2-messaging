require 'json'

module Messaging
  module ActiveRecord
    include SchemaTools::Modules::AsSchema

    def self.included(base)
      return if @messaging_enabled
      base.after_commit :post_to_messaging
      base.extend(Messaging::ActiveRecord::ClassMethods)

      @messaging_enabled = true
    end

    def post_to_messaging
      Messaging::Deliver.perform_later(
        post_to_messaging_klass.new(post_to_messaging_attributes),
        topic: post_to_messaging_topic, key: post_to_messaging_key
      )
    end

    def post_to_messaging!
      Messaging::Deliver.perform_now(
        post_to_messaging_klass.new(post_to_messaging_attributes),
        topic: post_to_messaging_topic, key: post_to_messaging_key
      )
    end

    def post_to_messaging_klass
      @post_to_messaging_klass ||= "Messages::#{self.class.schema_name.classify}".constantize
    end

    def post_to_messaging_attributes
      as_schema_hash
    end

    def post_to_messaging_key
      "#{self.class.schema_name}-#{id}"
    end

    def post_to_messaging_topic
      'catalog-changes'
    end

    module ClassMethods
      def schema_name
        model_name.param_key
      end
    end
  end
end
