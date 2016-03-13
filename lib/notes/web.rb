require 'socket'

class Notes
  class Web
    attr_accessor :app, :server_data, :server

    def initialize(app, server_data)
      @app = app
      @server_data = server_data
      @server = TCPServer.new(server_data[:Host], server_data[:Port])
    end

    def start
      loop do
        socket = server.accept
        response = app.call(parse_request(socket))
        write_response(response, socket)
        socket.close
      end
    end

    def write_response(response, socket)
      socket.puts "HTTP/1.1 #{response[0]}\r"
      response[1].each do |key, value|
        socket.puts "#{key}: #{value}\r"
      end

      socket.puts "\r"
      socket.print response[2].join
      socket.puts
    end

    def parse_request(socket)
      env = {}
      request = []

      socket.gets.split (" ")
      require "pry"
      binding.pry
      env.store("Path_Info", socket.gets.chomp)
      until request[-1] == "\r\n"
        request << socket.gets
      end
      request.pop

      request.each do |headers|
        kv_pairs = headers.chomp.split ": "
        kv_pairs[0].upcase
        env.store(kv_pairs[0], kv_pairs[1])
      end
      env.store("body", socket.read(env["CONTENT_LENGTH"].to_i))
      env
    end

    def stop
      server.close
    end
  end
end
