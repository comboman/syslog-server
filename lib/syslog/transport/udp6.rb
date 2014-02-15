require 'socket'

require 'syslog/transport/udp'

module Syslog
  module Transport

    class UDP6Transport < UDPTransport
      def initialize(port_or_hostname, port = nil)
        super (port.nil? ? '::' : port_or_hostname),
              (port.nil? ? port_or_hostname : port),
              Socket::AF_INET6
      end
    end

  end
end
