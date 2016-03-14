require 'socket'
require 'stringio'

class Notes
  class Server
    attr_accessor :app, :server_data, :server

    def initialize(app, server_data)
      @app = app
      @server_data = server_data
      @server = TCPServer.new(server_data[:Host], server_data[:Port])
    end

    def start
      loop do
        socket = server.accept
        response = app.call(Notes::Server.get_and_parse_request(socket))
        Notes::Server.write_response(response, socket)
        socket.close
      end
    end

    def self.write_response(response, socket)
      socket.write "HTTP/1.1 #{response[0]}\r\n"
      response[1].each do |key, value|
        socket.write "#{key}: #{value}\r\n"
      end

      socket.write "\r\n"
      socket.write response[2].join
      socket
    end
    def self.get_and_parse_request(socket)
      env = {}
      request = ""

      first_line = socket.gets.chomp.split(" ")
      env.store("REQUEST_METHOD", first_line[0])
      path = first_line[1].split("?")
      env.store("PATH_INFO", path[0])
      env.store("QUERY_STRING", path[1])
      env.store("SERVER_PROTOCOL", first_line[2])

      until request == "\r\n"
        if request != ""
          kv_pair = request.chomp.split(": ")

          if kv_pair[0][/content/i]
            env.store("#{kv_pair[0].upcase.gsub "-", "_"}", kv_pair[1])
          else
            env.store("HTTP_#{kv_pair[0].upcase.gsub "-", "_"}", kv_pair[1])
          end
        end

        request = socket.gets
      end

      body = socket.read(env["CONTENT_LENGTH"].to_i)
      env.store("rack.input", StringIO.new(body))

      server_data = env["HTTP_HOST"].split(":")
      env.store("SERVER_NAME", server_data[0])
      env.store("SERVER_PORT", server_data[1])
      env.store("REQUEST_URI", "http://#{env["HTTP_HOST"]}")
      env
    end

    def stop
      server.close
    end
  end
end
