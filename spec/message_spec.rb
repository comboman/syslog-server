require 'minitest/autorun'

require 'syslog/message'

describe Syslog::Message do
  it 'should recognise example 1 from section 6.5 of the RFC' do
    m = Syslog::Message.new <<-EOS.strip
<34>1 2003-10-11T22:14:15.003Z mymachine.example.com su - ID47 - 'su root' failed for lonvick on /dev/pts/8
    EOS

    m.facility.must_equal 4
    m.severity.must_equal 2
    m.datetime.year.must_equal 2003
    m.datetime.month.must_equal 10
    m.datetime.day.must_equal 11
    m.datetime.hour.must_equal 22
    m.datetime.minute.must_equal 14
    m.datetime.second.must_equal 15
    m.datetime.second_fraction.must_equal '3/1000'.to_r
    m.hostname.must_equal 'mymachine.example.com'
    m.app_name.must_equal 'su'
    m.procid.must_be_nil
    m.msgid.must_equal 'ID47'
    m.structured_data.must_be_nil
    m.message.must_equal "'su root' failed for lonvick on /dev/pts/8"
  end

  it 'should recognise example 2 from section 6.5 of the RFC' do
    m = Syslog::Message.new <<-EOS.strip
<165>1 2003-08-24T05:14:15.000003-07:00 192.0.2.1 myproc 8710 - - %% It's time to make the do-nuts.
    EOS

    m.facility.must_equal 20
    m.severity.must_equal 5
    m.datetime.year.must_equal 2003
    m.datetime.month.must_equal 8
    m.datetime.day.must_equal 24
    m.datetime.hour.must_equal 5
    m.datetime.minute.must_equal 14
    m.datetime.second.must_equal 15
    m.datetime.second_fraction.must_equal '3/1000000'.to_r
    m.hostname.must_equal '192.0.2.1'
    m.app_name.must_equal 'myproc'
    m.procid.must_equal '8710'
    m.msgid.must_be_nil
    m.structured_data.must_be_nil
    m.message.must_equal "%% It's time to make the do-nuts."
  end

  it 'should recognise example 3 from section 6.5 of the RFC' do
    m = Syslog::Message.new <<-EOS.strip
<165>1 2003-10-11T22:14:15.003Z mymachine.example.com evntslog - ID47 [exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"] An application event log entry...
    EOS

    m.facility.must_equal 165 / 8
    m.severity.must_equal 165 % 8
    m.datetime.year.must_equal 2003
    m.datetime.month.must_equal 10
    m.datetime.day.must_equal 11
    m.datetime.hour.must_equal 22
    m.datetime.minute.must_equal 14
    m.datetime.second.must_equal 15
    m.datetime.second_fraction.must_equal '3/1000'.to_r
    m.hostname.must_equal 'mymachine.example.com'
    m.app_name.must_equal 'evntslog'
    m.procid.must_be_nil
    m.msgid.must_equal 'ID47'
    m.structured_data.must_equal '[exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"]'
    m.message.must_equal 'An application event log entry...'
  end

  it 'should recognise example 4 from section 6.5 of the RFC' do
    m = Syslog::Message.new <<-EOS.strip
<165>1 2003-10-11T22:14:15.003Z mymachine.example.com evntslog - ID47 [exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"][examplePriority@32473 class="high"]
    EOS

    m.facility.must_equal 165 / 8
    m.severity.must_equal 165 % 8
    m.datetime.year.must_equal 2003
    m.datetime.month.must_equal 10
    m.datetime.day.must_equal 11
    m.datetime.hour.must_equal 22
    m.datetime.minute.must_equal 14
    m.datetime.second.must_equal 15
    m.datetime.second_fraction.must_equal '3/1000'.to_r
    m.hostname.must_equal 'mymachine.example.com'
    m.app_name.must_equal 'evntslog'
    m.procid.must_be_nil
    m.msgid.must_equal 'ID47'
    m.structured_data.must_equal '[exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"][examplePriority@32473 class="high"]'
    m.message.must_be_nil
  end

  it 'should be able to reconstruct itself by building from the result of to_s' do
    m = Syslog::Message.new <<-EOS.strip
<165>1 2003-08-24T05:14:15.000003-07:00 192.0.2.1 myproc 8710 - - %% It's time to make the do-nuts.
    EOS
    m2 = Syslog::Message.new(m.to_s)

    %i{
      facility severity datetime hostname app_name
      procid msgid structured_data message
    }.each do |prop|
      m.send(prop).must_equal m2.send(prop)
    end
  end
end
