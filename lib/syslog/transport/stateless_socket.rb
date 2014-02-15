require 'socket'

require 'syslog/limit'
require 'syslog/transport/queue'

module Syslog
  module Transport

    class StatelessSocketTransport < QueueTransport
      def initialize(socket)
        super()

        @thread = Thread.new do
          begin
            loop do
              data, sender = socket.recvfrom(Syslog::Limit::MAXIMUM_SIZE)
              unless (msg = Syslog::Message.parse(data)).nil?
                push(msg, sender)
              end
            end
          ensure
            socket.close
          end
        end
      end

      def close
        unless @thread.nil?
          @thread.kill
          @thread.join
          @thread = nil
        end
      end
    end

  end
end
