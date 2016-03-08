require 'notes/web' # <-- you'll need to make this
require 'net/http'  # this is from the stdlib

class AcceptanceTest < Minitest::Test
  def port
    9292
  end

  def run_server(port, app, &block)
    server = Notes::Web.new(app, Port: port, Host: 'localhost')
    require "pry"
    thread = Thread.new { server.start } # The thread allows the server to sit and wait for a request, but still return to here so we can send it.
    thread.abort_on_exception = true
    block.call
  ensure
    thread.kill
    server.stop
  end

  def test_it_accepts_and_responds_to_a_web_request
    path_info = "this value should be overridden by the app!"

    app = Proc.new do |env_hash|
      path_info = env_hash['PATH_INFO']
      body      = "hello, class ^_^"
      [200, {'Content-Type' => 'text/plain', 'Content-Length' => body.length, 'omg' => 'bbq'}, [body]]
    end

    run_server port, app do
      response = Net::HTTP.get_response('localhost', '/path', port)
      assert_equal "200",              response.code
      assert_equal 'bbq',              response.header['omg']
      assert_equal "hello, class ^_^", response.body
    end
  end


  def test_it_handles_multiple_requests
    app = Proc.new { |env_hash| [200, {'Content-Type' => 'text/plain'}, []] }

    run_server port, app do
      assert_equal "200", Net::HTTP.get_response('localhost', '/', port).code
      assert_equal "200", Net::HTTP.get_response('localhost', '/', port).code
    end
  end


  def test_it_starts_on_the_specified_port
    other_port = 9293
    app = Proc.new do |env_hash|
      [ 200,
        {'Content-Type' => 'text/plain', 'Content-Length' => 5},
        ['hello']
      ]
    end

    run_server other_port, app do
      assert_equal 'hello', Net::HTTP.get_response('localhost', '/', other_port).body
    end
  end
end
