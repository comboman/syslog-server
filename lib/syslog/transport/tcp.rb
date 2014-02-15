require 'socket'

require 'syslog/transport/stateful_socket'

module Syslog
  module Transport

    class TCPTransport < StatefulSocketTransport
      def initialize(host_or_port, port = nil)
        if port.nil?
          host = ''
          port = host_or_port
        else
          host = host_or_port
        end

        super(TCPServer.new(host, port))
      end
    end

  end
end
