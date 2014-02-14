require 'socket'

require 'syslog/limit'

module Syslog
  module Transport

    class UDPTransport
      def initialize(port_or_hostname, port = nil, socket = nil)
        if port.nil?
          host = ''
          port = port_or_hostname
        else
          host = port_or_hostname
        end

        @sock = socket || UDPSocket.new
        @sock.bind(host, port)
      end

      def read
        msg = nil

        while msg.nil?
          begin
            data, sender = @sock.recvfrom(Syslog::Limit::MAXIMUM_SIZE)
            msg = [ Syslog::Message.new(data), sender ]
          rescue ArgumentError
            # Malformed data; ignore.
          end
        end

        msg
      end

      def close
        @sock.close
      end
    end

  end
end
