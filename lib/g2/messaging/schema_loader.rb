require 'json_schema_tools'

module Messaging
  class SchemaLoader
    attr_reader :path

    def initialize(path = config.schema_path)
      @path = path
    end

    def load_all
      SchemaTools::KlassFactory.build namespace: ::Messages, path: path
    end

    def config
      Messaging.config
    end
  end
end
