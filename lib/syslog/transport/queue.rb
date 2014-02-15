require 'thread'

module Syslog
  module Transport

    class QueueTransport
      def initialize
        @messages_mutex = Mutex.new
        @messages_cv = ConditionVariable.new
        @messages = []
      end

      def read
        @messages_mutex.synchronize do
          @messages_cv.wait(@messages_mutex) if @messages.empty?
          @messages.pop
        end
      end

      def close
      end

      protected

      def push(msg, sender)
        @messages_mutex.synchronize do
          @messages.unshift([msg, sender])
          @messages_cv.signal
        end

        nil
      end
    end

  end
end
