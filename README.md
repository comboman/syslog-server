# Syslog::Server

A syslog server library written in Ruby.

## Examples

Creating a TCP syslog server listening on port 514 (the de facto standard):

    require 'syslog/server'

    Syslog::Server.tcp(514)

Creating a UDP syslog server listening on address 127.0.0.1, port 1234:

    require 'syslog/server'

    Syslog::Server.udp('127.0.0.1', 1234)
