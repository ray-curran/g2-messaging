require 'json_schema_tools'

module Messaging
  class SchemaLoader
    attr_reader :path, :namespace

    def initialize(path = config.schema_path, namespace: ::Messages)
      @path = path
      @namespace = namespace
    end

    def load_all
      SchemaTools::KlassFactory.build namespace: namespace, path: path

      subdir_list = Dir.entries(path).reject { |i| %w(. ..).include?(i) }.select { |o| File.directory?(File.join(path, o)) }

      subdir_list.each do |dir|
        nested = next_namespace(dir.camelize)
        Messaging::SchemaLoader.new(File.join(path, dir), namespace: nested).load_all
      end
    end

    def next_namespace(name)
      namespace.const_defined?(name) ? namespace.const_get(name) : namespace.const_set(name, Module.new)
    end

    def config
      Messaging.config
    end
  end
end
