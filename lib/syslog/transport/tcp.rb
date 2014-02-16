require 'socket'

require 'syslog/transport/stateful_socket'

module Syslog
  module Transport

    class TCPSyslogSocket
      def initialize(sock)
        @sock = sock
      end

      def recv(max_len)
        # TODO: state machine here... we can either receive an octet-counting
        # style message or an LF-terminated message.  remember to enforce max
        # length.
      end

      def close
        @sock.close unless @sock.closed?
      end
    end

    class TCPSyslogServer
      def initialize(sock)
        @sock = sock
      end

      def accept
        TCPSyslogSocket.new(@sock.accept)
      end

      def close
        @sock.close unless @sock.closed?
      end
    end

    class TCPTransport < StatefulSocketTransport
      def initialize(host_or_port, port = nil)
        if port.nil?
          host = ''
          port = host_or_port
        else
          host = host_or_port
        end

        super(TCPSyslogServer.new(TCPServer.new(host, port)))
      end
    end

  end
end
