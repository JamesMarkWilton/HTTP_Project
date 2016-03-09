require 'socket'

class Notes
  class Web
    attr_reader :app, :server_data, :env, :server

    def initialize(app, server_data)
      @app = app
      @server_data = server_data
      @server = TCPServer.new(server_data[:Host], server_data[:Port])
      @env = {}
    end

    def start
      socket = server.accept
      app_data = app.call(env)

      socket.puts "HTTP/1.1 #{app_data[0]}\r"
      app_data[1].each do |key, value|
        socket.puts "#{key}: #{value}\r"
      end

      socket.puts "\r"
      socket.print app_data[2].join

      socket2 = server.accept
      app_data = app.call(env)

      socket2.puts "HTTP/1.1 #{app_data[0]}\r"
      app_data[1].each do |key, value|
        socket2.puts "#{key}: #{value}\r"
      end

      socket2.puts "\r"
      socket2.print app_data[2].join
      socket2.close
      server.close
    end

    def stop
    end
  end
end
