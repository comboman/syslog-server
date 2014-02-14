module Syslog
  module Pattern

    #--
    # Based on RFC5424, section 6.
    #++

    NILVALUE          = /-/n
    PRINTUSASCII      = /[\x21-\x7e]/n
    HOSTNAME          = /#{NILVALUE}|#{PRINTUSASCII}{1,255}/n
    SD_NAME           = /[\x21\x23-\x3c\x3e-\x5c\x5e-\x7e]{1,32}/n
    SD_ID             = /#{SD_NAME}/n
    PARAM_NAME        = /#{SD_NAME}/n
    PARAM_VALUE       = /(?:\\"|\\\]|\\\\|[\x00-\x21\x23-\x5b\x5e-\xff])*/n
    SD_PARAM          = /#{PARAM_NAME}="#{PARAM_VALUE}"/n
    SD_ELEMENT        = /\[#{SD_ID}(?: #{SD_PARAM})*\]/n
    STRUCTURED_DATA   = /#{NILVALUE}|#{SD_ELEMENT}+/n
    TIME_HOUR         = /\d{2}/n
    TIME_MINUTE       = /\d{2}/n
    TIME_SECOND       = /\d{2}/n
    TIME_SECFRAC      = /\.\d{1,6}/n
    PARTIAL_TIME      = /#{TIME_HOUR}:#{TIME_MINUTE}:#{TIME_SECOND}(?:#{TIME_SECFRAC})?/n
    TIME_NUMOFFSET    = /[+-]?#{TIME_HOUR}:#{TIME_MINUTE}/n
    TIME_OFFSET       = /Z|#{TIME_NUMOFFSET}/n
    FULL_TIME         = /#{PARTIAL_TIME}#{TIME_OFFSET}/n
    DATE_MDAY         = /\d{2}/n
    DATE_MONTH        = /\d{2}/n
    DATE_FULLYEAR     = /\d{4}/n
    FULL_DATE         = /#{DATE_FULLYEAR}-#{DATE_MONTH}-#{DATE_MDAY}/n
    TIMESTAMP         = /#{NILVALUE}|#{FULL_DATE}T#{FULL_TIME}/n
    VERSION           = /[1-9][0-9]{,2}/n
    PRIVAL            = /\d{1,3}/n
    PRI               = /<(?<priority>#{PRIVAL})>/n
    MSGID             = /#{NILVALUE}|#{PRINTUSASCII}{1,32}/n
    PROCID            = /#{NILVALUE}|#{PRINTUSASCII}{1,128}/n
    APP_NAME          = /#{NILVALUE}|#{PRINTUSASCII}{1,48}/n
    HEADER            = /#{PRI}(?<version>#{VERSION}) (?<timestamp>#{TIMESTAMP}) (?<hostname>#{HOSTNAME}) (?<app_name>#{APP_NAME}) (?<procid>#{PROCID}) (?<msgid>#{MSGID})/n
    MSG               = /.*/n
    MESSAGE           = /\A(?<header>#{HEADER}) (?<structured_data>#{STRUCTURED_DATA})(?: (?<message>#{MSG}))?\z/n

  end
end
