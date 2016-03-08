require 'socket'

class Notes
  class Web
    attr_reader :host, :port
    def initialize(app, port, host)
      @app = app
      @port = port
      @host = host
    end

    def start(app, port, host)
      TCPServer.new(host[:Host], port[:Port])
    end
  end
end
