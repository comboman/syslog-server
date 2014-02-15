require 'minitest/autorun'

require 'syslog/transport/udp6'

describe Syslog::Transport::UDP6Transport do
  before do
    @transport = Syslog::Transport::UDP6Transport.new('::1', 1234)
    @sock = UDPSocket.new(Socket::AF_INET6)
  end

  after do
    @transport.close
    @sock.close
  end

  it 'should provide valid received messages' do
    @sock.send  "<165>1 2003-08-24T05:14:15.000003-07:00 192.0.2.1 myproc 8710 - - %% It's time to make the do-nuts.",
                0,
                '::1',
                1234

    sleep 0.1

    msg, sender = @transport.read
    msg.wont_be_nil
    sender.wont_be_nil
    msg.must_be_instance_of Syslog::Message
  end
end
