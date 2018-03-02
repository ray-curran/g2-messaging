require 'racecar'

module Messaging
  class RacecarConsumer < Racecar::Consumer
    class << self
      def subscribes_to(*topics, start_from_beginning: true, max_bytes_per_partition: 1 * 1024 * 1024)
        prefixed_topics = topics.map { |i| "#{Messaging.config.prefix}#{i}" }
        super *prefixed_topics, start_from_beginning: start_from_beginning, max_bytes_per_partition: max_bytes_per_partition
      end
    end
  end
end
