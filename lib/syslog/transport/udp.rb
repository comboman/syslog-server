require 'socket'

require 'syslog/limit'
require 'syslog/transport/stateless_socket'

module Syslog
  module Transport

    class UDPTransport < StatelessSocketTransport
      def initialize(port_or_hostname, port = nil, sock_proto = Socket::AF_INET)
        @sock = UDPSocket.new(sock_proto)

        if port.nil?
          host = ''
          port = port_or_hostname
        else
          host = port_or_hostname
        end

        @sock.bind(host, port)

        super(@sock)
      end

      def close
        @sock.close unless @sock.closed?
      end
    end

  end
end
