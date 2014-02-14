require 'socket'

require 'syslog/limit'
require 'syslog/message'

module Syslog
  module Transport

    class TCPClientHandler
      def initialize(sock)
        @peer_addr = sock.peeraddr
        @messages = []
        @messages_mutex = Mutex.new

        # redo all of this.  instead of doing non-blocking
        # operations, it's better to block and use @thread.raise
        # to raise an exception in the thread (this is how
        # GServer does it).

        @stop = false
        Thread.new do
          until stopped?
            begin
              data = sock.recv_nonblock(Syslog::Limit::MAXIMUM_SIZE)
              push(Syslog::Message.new(data))
            rescue IO::WaitReadable
              # No data.
            rescue ArgumentError
              # Malformed message; ignore.
            rescue
              close
            end

            sleep 0.1
          end

          sock.close
        end
      end

      def push(msg)
        @messages_mutex.syncrhonize { @messages.unshift([msg, @peer_addr]) }
      end

      def pop
        @messages_mutex.synchronize { @messages.pop }
      end

      def stopped?
        @stop
      end

      def close
        @stop = true
      end
    end

    class TCPTransport
      def initialize(host_or_port, port = nil)
        @messages = []
        @messages_mutex = Mutex.new

        @stop = false

        if port.nil?
          host = ''
          port = host_or_port
        else
          host = host_or_port
        end

        socket ||= TCPServer.new(host, port)

        Thread.new do
          clients = []

          until stopped?
            begin
              new_client = socket.accept_nonblock
              clients.push(TCPClientHandler.new(new_client))
            rescue IO::WaitReadable
              # No new connections.
            end

            clients.each do |c|
              msg_and_addr = c.pop
              push(msg_and_addr) unless msg_and_addr.nil?
            end

            sleep 0.1
          end
        end
      end

      def push(msg_and_addr)
        @messages_mutex.synchronize { @messages.unshift(msg_and_addr) }
      end

      def pop
        @messages_mutex.synchronize { @messages.pop }
      end

      def stopped?
        @stop
      end

      def close
        @stop = true
      end
    end

  end
end
