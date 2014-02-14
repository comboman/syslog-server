require 'minitest/autorun'

require 'syslog/transport/udp'

describe Syslog::Transport::UDPTransport do
  before do
    @transport = Syslog::Transport::UDPTransport.new('127.0.0.1', 1234)
    @sock = UDPSocket.new
  end

  after do
    @transport.close
    @sock.close
  end

  it 'should provide valid received messages' do
    @sock.send  "<165>1 2003-08-24T05:14:15.000003-07:00 192.0.2.1 myproc 8710 - - %% It's time to make the do-nuts.",
                0,
                '127.0.0.1',
                1234

    sleep 0.1

    msg, sender = @transport.read
    msg.wont_be_nil
    sender.wont_be_nil
    msg.must_be_instance_of Syslog::Message
  end

  it 'should return nil for invalid messages' do
    @sock.send "blah blah blah", 0, '127.0.0.1', 1234

    sleep 0.1

    msg, sender = @transport.read
    msg.must_be_nil
    sender.must_be_nil
  end

  it 'should return nil if no data has been received' do
    msg, sender = @transport.read
    msg.must_be_nil
    sender.must_be_nil
  end
end
