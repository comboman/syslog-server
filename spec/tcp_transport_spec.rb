require 'minitest/autorun'
require 'socket'

require 'syslog/message'
require 'syslog/transport/tcp'

describe Syslog::Transport::TCPTransport do
  after do
    @transport.close unless @transport.nil?
    @sock.close unless @sock.nil?
  end

  it 'listens on the specified host/port' do
    @transport = Syslog::Transport::TCPTransport.new('127.0.0.1', 9999)
    @sock = TCPSocket.new('127.0.0.1', 9999)

    # The above will raise an exception on failure, but...
    @sock.closed?.must_equal false
  end

  it 'accepts syslog messages sent over TCP' do
    @transport = Syslog::Transport::TCPTransport.new('127.0.0.1', 9999)
    @sock = TCPSocket.new('127.0.0.1', 9999)

    @sock.print("<34>1 2003-10-11T22:14:15.003Z mymachine.example.com su - ID47 - 'su root' failed for lonvick on /dev/pts/8")
    @sock.flush

    msg, sender = @transport.read

    msg.must_be_instance_of Syslog::Message
    sender.wont_be_nil
  end
end
