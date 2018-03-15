require 'g2/messaging/backends/controller'

module Messaging
  module Backends
    class Inline
      include Messaging::Backends::Controller

      def self.perform_now(*args)
        new.perform(*args)
      end

      def self.perform_later(*args)
        new.perform(*args)
      end
    end
  end
end
