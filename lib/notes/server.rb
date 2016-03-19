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

    def stop
      server.close
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
      env = first_line_parse(socket.gets)

      env = convert_request(Notes::Server.get(socket), env)
      body = socket.read(env["CONTENT_LENGTH"].to_i)
      env.store("rack.input", StringIO.new(body))
      Notes::Server.format_notes(env) if env["REQUEST_METHOD"] == "PUT"
      env
    end

    def self.first_line_parse(first_line)
      method, path, protocol = first_line.chomp.split(" ")
      env = {"REQUEST_METHOD" => method, "SERVER_PROTOCOL" => protocol}

      path, query = path.split("?")
      env.store("PATH_INFO", path)
      env.store("QUERY_STRING", query)
      env
    end

    def self.get(socket)
      request = []
      loop do
        request << socket.gets
        break if request[-1] == "\r\n"
      end
      request.pop
      request
    end

    def self.convert_request(request, env)
      request.each do |line|
        key, value = line.split(": ")

        if key[/content/i]
          env.store(key.upcase.tr("-", "_"), value.chomp)
        else
          env.store("HTTP_#{key.upcase.tr("-", "_")}", value.chomp)
        end
      end
      env
    end
  end
end
