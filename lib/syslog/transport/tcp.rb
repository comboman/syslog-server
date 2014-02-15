require 'socket'

require 'syslog/limit'
require 'syslog/message'

module Syslog
  module Transport

    class TCPTransport
      def initialize(host_or_port, port = nil)
        if port.nil?
          host = ''
          port = host_or_port
        else
          host = host_or_port
        end
      end
    end

  end
end
