# Library for controlling Onkyo receivers over TCP/IP.

module EISCP
  VERSION = '0.0.4'
end

require_relative './eiscp/receiver'
require_relative './eiscp/message'
require_relative './eiscp/dictionary'
