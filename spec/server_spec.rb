require 'minitest/autorun'

require 'syslog/server'

describe Syslog::Server do
  it 'should be asynchronous' do
    transport = Object.new
    class << transport
      def read
        sleep 10
      end

      def close
      end
    end

    server = Syslog::Server.new(transport)
    server.stop
    server.stopped?.must_equal true
  end

  it 'should yield messages and call close on stop' do
    block = MiniTest::Mock.new
    block.expect(:call, nil, [ 123 ])

    transport = MiniTest::Mock.new
    transport.expect(:read, 123)
    transport.expect(:close, nil)

    server = Syslog::Server.new(transport) do |msg|
      block.call(msg)
      server.stop
    end

    sleep 0.5

    block.verify
    transport.verify
  end
end
