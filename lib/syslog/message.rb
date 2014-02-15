require 'date'

require 'syslog/pattern'

module Syslog
  class Message
    attr_accessor :facility,
                  :severity,
                  :version,
                  :datetime,
                  :hostname,
                  :app_name,
                  :procid,
                  :msgid,
                  :structured_data,
                  :message

    def initialize(str)
      m = Syslog::Pattern::MESSAGE.match(str)
      fail(ArgumentError, 'Not a valid syslog message.') if m.nil?

      pri = m[:priority].to_i
      @facility = pri / 8
      @severity = pri % 8

      @version          = m[:version].to_i
      @datetime         = maybe_nil(m[:timestamp]) { |t| DateTime.parse(t) }
      @hostname         = maybe_nil(m[:hostname])
      @app_name         = maybe_nil(m[:app_name])
      @procid           = maybe_nil(m[:procid])
      @msgid            = maybe_nil(m[:msgid])
      @structured_data  = maybe_nil(m[:structured_data])
      @message          = m[:message]
    end

    def maybe_nil(val)
      unless val == '-'
        block_given? ? yield(val) : val
      end
    end
    private :maybe_nil

    def nil_or(val)
      if val.nil?
        '-'
      else
        block_given? ? yield(val) : val
      end
    end
    private :nil_or

    def to_s
      str = ''
      str << "<#{(@facility * 8) + @severity}>#{@version} "
      str << "#{nil_or(@datetime) { |d| d.strftime('%Y-%m-%dT%H:%M:%S.%6N%:z') }} "
      str << "#{nil_or(@hostname)} "
      str << "#{nil_or(@app_name)} "
      str << "#{nil_or(@procid)} "
      str << "#{nil_or(@msgid)} "
      str << "#{nil_or(@structured_data)}"
      str << " #{@message}" unless @message.nil?
      str
    end

    def self.parse(str)
      begin
        Message.new(str)
      rescue ArgumentError
        nil
      end
    end
  end
end
