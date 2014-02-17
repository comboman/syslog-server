require 'socket'

require 'syslog/limit'
require 'syslog/message'
require 'syslog/transport/queue'

module Syslog
  module Transport

    class TCPTransport < QueueTransport
      Client = Struct.new(:sock, :buffer)

      def initialize(host_or_port, port = nil)
        super()

        if port.nil?
          host = ''
          port = host_or_port
        else
          host = host_or_port
        end

        @sock = TCPServer.new(host, port)

        clients = []
        clients_mutex = Mutex.new

        @accept_thread = Thread.new do
          begin
            loop do
              new_sock = @sock.accept
              new_client = Client.new(new_sock, '')
              clients_mutex.synchronize { clients.push(new_client) }
            end
          ensure
            @sock.close unless @sock.closed?
          end
        end

        @service_thread = Thread.new do
          begin
            loop do
              # filter out any closed clients.
              clients_mutex.synchronize do
                clients.reject! { |c| c.sock.closed? }
              end

              clients_snapshot = clients_mutex.synchronize { clients.dup }
              have_data_for = IO.select(clients_snapshot.map(&:sock), nil, nil, 1)

              next if have_data_for.nil?

              # if we have data on any, process them:
              have_data_for[0].zip(clients_snapshot).each do |sock, client|
                next if sock.nil?

                r = sock.recv(Syslog::Limit::MAXIMUM_MESSAGE_SIZE)
                if r.empty?
                  # this means EOF for TCP sockets.
                  sock.close
                  next
                end

                client.buffer << r

                loop do
                  # octet-counting:
                  if client.buffer =~ /\A(?<length>\d+) (?<data>.*)\z/
                    length, data = Regexp.last_match[:length].to_i, Regexp.last_match[:data]

                    if data.size >= length
                      client.buffer = data[length..-1]

                      unless (msg = Syslog::Message.parse(data[0...length])).nil?
                        push(msg, client.sock.peeraddr)
                      end
                    end
                  # non-transparent-framing:
                  elsif !(eol = client.buffer.index("\r")).nil?
                    data = client.buffer[0...eol]
                    client.buffer = client.buffer[eol + 1..-1]

                    unless (msg = Syslog::Message.parse(data)).nil?
                      push(msg, client.sock.peeraddr)
                    end
                  # no more complete messages:
                  else
                    break
                  end
                end
              end
            end
          ensure
            clients_mutex.synchronize do
              clients.each { |c| c.sock.close unless c.sock.closed? }
            end
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
