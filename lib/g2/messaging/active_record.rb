require 'json'
require 'active_support'

module Messaging
  module ActiveRecord
    include SchemaTools::Modules::AsSchema
    extend ActiveSupport::Concern

    included do
      after_commit :post_to_messaging
      extend(Messaging::ActiveRecord::ClassMethods)
    end

    def post_to_messaging
      post_to_messaging_klass.new(post_to_messaging_attributes).deliver_later(
        topic: post_to_messaging_topic, key: post_to_messaging_key
      )
    end

    def post_to_messaging!
      post_to_messaging_klass.new(post_to_messaging_attributes).deliver_now(
        topic: post_to_messaging_topic, key: post_to_messaging_key
      )
    end

    def post_to_messaging_klass
      @post_to_messaging_klass ||= "Messages::ChangedRecords::#{self.class.schema_name.classify}".constantize
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
