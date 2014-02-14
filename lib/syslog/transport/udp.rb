require 'socket'

require 'syslog/limit'
require 'syslog/message'

module Syslog
  module Transport

    class UDPTransport
      def initialize(port_or_hostname, port = nil, socket = nil)
        if port.nil?
          host = '' # <-- INADDR_ANY
          port = port_or_hostname
        else
          host = port_or_hostname
        end

        @sock = socket || UDPSocket.new
        @sock.bind(host, port)
      end

      def read
        data, sender = @sock.recvfrom_nonblock(Syslog::Limit::MAXIMUM_SIZE)
        [ Syslog::Message.new(data), sender ]
      rescue IO::WaitReadable
        # No data.
      rescue ArgumentError
        # Malformed data; ignore.
      end

      def close
        @sock.close
      end
    end

  end
end
