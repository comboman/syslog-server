require 'minitest/autorun'

require 'syslog/transport/datagram_socket'

describe Syslog::Transport::DatagramSocketTransport do
  it 'retrieves messages using #recvfrom' do
    sock = Object.new
    class << sock
      def recvfrom(n)
        if !@recv_done
          @recv_done = true
          [
            "<34>1 2003-10-11T22:14:15.003Z mymachine.example.com su - ID47 - 'su root' failed for lonvick on /dev/pts/8",
            :sender
          ]
        else
          sleep
        end
      end

      def close
      end
    end

    t = Syslog::Transport::DatagramSocketTransport.new(sock)

    msg, sender = t.read

    msg.must_be_instance_of Syslog::Message
    sender.must_equal :sender
  end

  it "calls #close on the socket when it itself is closed" do
    sock = Object.new
    class << sock
      def recvfrom(n)
        sleep
      end

      def close
        @closed = true
      end

      def closed?
        !!@closed
      end
    end

    t = Syslog::Transport::DatagramSocketTransport.new(sock)

    t.close
    sock.closed?.must_equal true
  end
end
