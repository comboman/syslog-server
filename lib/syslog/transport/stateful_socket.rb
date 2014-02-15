require 'socket'

require 'syslog/limit'
require 'syslog/message'
require 'syslog/transport/queue'

module Syslog
  module Transport

    class StatefulSocketTransport < QueueTransport
      def initialize(sock)
        super()

        @sock = sock

        clients = []
        clients_mutex = Mutex.new

        @accept_thread = Thread.new do
          begin
            loop do
              new = @sock.accept
              clients_mutex.synchronize { clients.push(new) }
            end
          ensure
            @sock.close unless @sock.closed?
          end
        end

        @service_thread = Thread.new do
          begin
            loop do
              clients_snapshot = clients_mutex.synchronize { clients.dup }
              have_data_for = IO.select(clients_snapshot, nil, nil, 1)
              clients.reject!(&:closed?)

              next if have_data_for.nil?

              # If we have data on any, process them:
              have_data_for[0].each do |client|
                data = client.recv(Syslog::Limit::MAXIMUM_SIZE)
                unless (msg = Syslog::Message.parse(data)).nil?
                  push(msg, client.peeraddr)
                end
              end
            end
          ensure
            clients_mutex.synchronize { clients.each { |c| c.close unless c.closed? } }
          end
        end
      end

      def close
        unless @accept_thread.nil?
          @accept_thread.kill
          @accept_thread.join
          @accept_thread = nil
        end

        unless @service_thread.nil?
          @service_thread.kill
          @service_thread.join
          @service_thread = nil
        end
      end
    end

  end
end
