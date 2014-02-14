require 'syslog/message'

module Syslog
  class Server
    VERSION = '1.0.0'

    def initialize(transport)
      parent = self
      @stop = false

      @thread = Thread.new do
        until parent.stopped?
          msg = transport.read
          yield msg unless msg.nil?
          sleep 0.1
        end
      end
    end

    def stop
      @stop = true
    end

    def stopped?
      @stop
    end
  end
end
