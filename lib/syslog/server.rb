require 'syslog/message'

module Syslog
  class Server
    VERSION = '1.0.0'

    def initialize(transport)
      @thread = Thread.new do
        begin
          loop { yield transport.read }
        ensure
          transport.close
        end
      end
    end

    def stop
      unless @thread.nil?
        @thread.kill
        @thread.join
        @thread = nil
      end
    end

    def stopped?
      @thread.nil?
    end
  end
end
