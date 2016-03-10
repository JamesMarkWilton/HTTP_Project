require 'socket'

class Notes
  class Web
    attr_accessor :app, :server_data, :env, :server

    def initialize(app, server_data)
      @app = app
      @server_data = server_data
      @server = TCPServer.new(server_data[:Host], server_data[:Port])
    end

    def start
      socket = server.accept
      stuff = socket.readlines

      env = {}
      parse_request(request, env)

      app_data = app.call(env)

      socket.puts "HTTP/1.1 #{app_data[0]}\r"
      app_data[1].each do |key, value|
        socket.puts "#{key}: #{value}\r"
      end

      socket.puts "\r"
      socket.print app_data[2].join
      socket.close
    end

    def parse_request(request, env)
      env.store("Path_Info", request.shift.chomp)
      body = request.pop
      if body != "\r\n"
        env.store("body", body)
      end

      headers = {}
      request.each do |element|
        if element != "\r\n"
          data = element.chomp.split ": "
          headers.store(data[0], data[1])
        end
      end

      env.store("headers", headers)
    end

    def stop
      server.close
    end
  end
end
