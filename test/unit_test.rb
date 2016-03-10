require 'minitest'
require 'notes/web'

class WebTest < Minitest::Test
  def test_makes_a_hash_of_the_request_data
    server = Notes::Web.new("some block", Host: "localhost", Port: 9294)
    request = ["Get HTTP/1.1\r\n", "One: 1\r\n", "Two: 2\r\n", "\r\n"]
    env = {}
    server.parse_request(request, env)

    assert_equal "Get HTTP/1.1", env["Path_Info"]
    assert_equal "1", env["headers"]["One"]
    assert_equal nil, env["body"]
    server.stop
  end
end
