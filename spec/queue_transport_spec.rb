require 'minitest/autorun'

require 'syslog/transport/queue'

describe Syslog::Transport::QueueTransport do
  subject { Syslog::Transport::QueueTransport.new }

  it "returns messages in the order they're pushed" do
    subject.send(:push, :msg1, :sender1)
    subject.send(:push, :msg2, :sender2)

    msg, sender = subject.read
    msg.must_equal :msg1
    sender.must_equal :sender1

    msg, sender = subject.read
    msg.must_equal :msg2
    sender.must_equal :sender2
  end
end
