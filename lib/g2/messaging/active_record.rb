module Messaging
  module ActiveRecord
    def self.included(base)
      return if @messaging_enabled

      base.after_commit :post_to_messaging

      @messaging_enabled = true
    end

    def post_to_messaging
      Messaging::Producer.produce({ model: self.class.model_name.name, data: post_to_messaging_attributes }.to_json,
                                  topic: post_to_messaging_topic,
                                  key: post_to_messaging_key)
    end

    def post_to_messaging!
      Messaging::Producer.produce!({ model: self.class.model_name.name, data: post_to_messaging_attributes }.to_json,
                                   topic: post_to_messaging_topic,
                                   key: post_to_messaging_key)
    end

    private

    def post_to_messaging_attributes
      attributes
    end

    def post_to_messaging_key
      "#{self.class.model_name.param_key}-#{id}"
    end

    def post_to_messaging_topic
      'catalog_changes'
    end
  end
end
