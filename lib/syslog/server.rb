require 'syslog/facility'
require 'syslog/limit'
require 'syslog/message'
require 'syslog/pattern'
require 'syslog/severity'
require 'syslog/transport'

module Syslog
  class Server
    VERSION = '1.0.1'

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

    class << self
      def self.transport(name)
        define_method(name) do |host_or_port, port = nil, &block|
          klass = Syslog::Transport.const_get("#{name.to_s.upcase}Transport")
          Syslog::Server.new(klass.new(host_or_port, port), &block)
        end
      end

      transport :tcp
      transport :udp
      transport :udp6
    end
  end
end
