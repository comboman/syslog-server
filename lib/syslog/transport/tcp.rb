require 'socket'

require 'syslog/limit'
require 'syslog/message'

module Syslog
  module Transport

    class TCPClientHandler
      def initialize(sock)
        @peer_addr = sock.peeraddr
        @messages_mutex = Mutex.new
        @messages = []
        @gone = false

        @thread = Thread.new do
          begin
            loop do
              begin
                push(Syslog::Message.new(sock.recv(Syslog::Limit::MAXIMUM_SIZE)))
              rescue ArgumentError
                # Malformed data; ignore.
              end
            end
          ensure
            sock.close unless sock.closed?
            @gone = true
          end
        end
      end

      def push(msg)
        @messages_mutex.synchronize { @messages.unshift([msg, @peer_addr]) }
      end

      def pop
        @messages_mutex.synchronize { @messages.pop }
      end

      def gone?
        @gone
      end

      def close
        unless @thread.nil?
          @thread.kill
          @thread.join
          @thread = nil
        end
      end
    end

    class TCPTransport
      def initialize(host_or_port, port = nil)
        if port.nil?
          host = ''
          port = host_or_port
        else
          host = host_or_port
        end

        # By creating this outside of the thread, we allow any exception to
        # pass down -- e.g. if the address is in use.
        sock = TCPServer.new(host, port)

        @clients_mutex = Mutex.new
        @clients = []
        @thread = Thread.new do
          begin
            loop do
              new_sock = sock.accept

              @clients_mutex.synchronize do
                @clients.push(TCPClientHandler.new(new_sock))
                @clients.reject!(&:gone?)
              end
            end
          ensure
            sock.close unless sock.closed?
            @clients_mutex.synchronize { @clients.each(&:close) }
          end
        end
      end

      def read
        msg = nil

        while msg.nil?
          msg = @clients_mutex.synchronize { @clients.lazy.map(&:pop).first }

          # FIXME: better solution than polling?  maybe use a condition
          # variable?  problem with that is that we miss receiving messages
          # immediately because of a race condition.
          sleep 0.1 if msg.nil?
        end

        msg
      end

      def stopped?
        @thread.nil?
      end

      def close
        unless @thread.nil?
          @thread.kill
          @thread.join
          @thread = nil
        end
      end
    end

  end
end
