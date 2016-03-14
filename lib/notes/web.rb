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
        response = app.call(get_and_parse(socket))
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

    def get_and_parse(socket)
      request = []
      until request[-1] == "\r\n"
        request << socket.gets
      end

      env = parse_request(request)
      env.store("BODY", socket.read(env["CONTENT_LENGTH"].to_i))
    end

    def parse_request(request)
      env = {}
      i = 0

      request_line = request.shift.split(" ")
      env.store("REQUEST_TYPE", request_line[0])
      env.store("PATH_INFO", request_line[1])
      env.store("REQUEST_LANG/VERSION", request_line[2])

      until request[i] == "\r\n"
        kv_pair = request[i].chomp.split(": ")

        if kv_pair[0][/content/i]
          env.store("#{kv_pair[0].upcase.gsub "-", "_"}", kv_pair[1])
        else
          env.store("HTTP_#{kv_pair[0].upcase.gsub "-", "_"}", kv_pair[1])
        end

        i += 1
      end
      request.pop

      env
    end

    def stop
      server.close
    end
  end
end
