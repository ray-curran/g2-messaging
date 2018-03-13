module Messaging
  class Logger
    attr_reader :logger

    def initialize(logger = nil)
      @logger = logger || Messaging::Logger::Stub.new
    end

    def info(message)
      logger.info(tagged(message))
    end

    def warn(message)
      logger.warn(tagged(message))
    end

    def debug(message)
      logger.debug(tagged(message))
    end

    def error(message)
      logger.error(tagged(message))
    end

    private

    def tagged(message)
      "[kafka] #{message}"
    end

    class Stub
      METHODS = %i(info warn debug error).freeze

      def method_missing(name, message)
        super unless METHODS.find { |i| i == name }

        puts message
      end
    end
  end
end
