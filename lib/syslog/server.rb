require 'syslog/message'

module Syslog
  class Server
    VERSION = '1.0.0'

    def initialize(transport)
<<<<<<< HEAD
      @stop = false

      @thread = Thread.new do
        until stopped?
          msg = transport.read
          yield msg unless msg.nil?
          sleep 0.1
=======
      @thread = Thread.new do
        begin
          loop { yield transport.read }
        ensure
          transport.close
>>>>>>> master
        end
      end
    end

    def stop
      unless @thread.nil?
        @thread.kill
        @thread = nil
      end
    end

    def stopped?
      @thread.nil?
    end
  end
end
