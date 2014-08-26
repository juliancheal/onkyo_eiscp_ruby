require 'socket'

module EISCP
  class Receiver
    module Connection
      # Receiver's connection socket
      attr_reader :socket
      # Receiver's connection thread
      attr_reader :thread
      # Most recent message received
      attr_reader :last

      # Default connection timeout value in seconds
      DEFAULT_TIMEOUT = 0.5

      # Default Onkyo eISCP port
      ONKYO_PORT = 60_128

      # Create a new connection thread. Also accepts a block that will run
      # whenver a message is received. You can pass the Message object in with
      # your block. This is the method #new uses to create the initial thread.
      #
      def start_thread(&block)
        @thread && @thread.kill
        @thread = Thread.new do
          loop do
            recv
            if block
              block.call(msg)
            end
          end
        end
      end

      # This handles the background thread for monitoring messages from the
      # receiver.
      #
      # If a block is given, it can be used to setup a callback when a message
      # is received.
      #
      def connect(host, port = ONKYO_PORT, &block)
        begin
          @socket = TCPSocket.new(host, port)
          start_thread(&block)
        rescue => e
          puts e
        end
      end

      # Sends an EISCP::Message object or string on the network
      #
      def send(eiscp, timeout = DEFAULT_TIMEOUT)
        if eiscp.is_a? EISCP::Message
          @socket.puts(eiscp.to_eiscp)
        elsif eiscp.is_a? String
          @socket.puts eiscp
        end
      end

      # Reads the socket and returns and EISCP::Message
      #
      def recv(timeout = DEFAULT_TIMEOUT)
        message = ''
        until message.match(/\r\n$/) do
          message << @socket.gets
        end
        @last = message
      end

      # Sends an EISCP::Message object or string on the network and returns recieved data string.
      #
      def send_recv(eiscp, timeout = DEFAULT_TIMEOUT)
        if eiscp.is_a? EISCP::Message
          @socket.puts(eiscp.to_eiscp)
        elsif eiscp.is_a? String
          @socket.puts(eiscp)
        end
        sleep DEFAULT_TIMEOUT
        last
      end
    end
  end
end