require 'socket'

class Notes
  class Web
    attr_reader :app, :server_data
    def initialize(app, server_data)
      @app = app
      @server_data = server_data
      @server = nil
    end

    def start
      app_data = []

      @server =  TCPServer.new(server_data[:Host], server_data[:Port])
      app_data = @app.call(server_data)
      @server.puts "POST /path #{app_data[0]}\r\n"
      @server.puts app_data[1]

    end

    def stop
      @server.close
    end
  end
end
