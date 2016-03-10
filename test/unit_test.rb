require 'minitest'
require 'notes/web'

class WebTest < Minitest::Test
  def test_makes_a_hash_of_the_request_data
    server = Notes::Web.new("some block", Host: "localhost", Port: 9294)
    data = ["Get HTTP/1.1\r\n", "One: 1\r\n", "Two: 2\r\n", "\r\n"]
    server.parse_request(data)

    assert_equal "Get HTTP/1.1", server.env["Path_Info"]
    assert_equal "1", server.env["headers"]["One"]
    assert_equal nil, server.env["body"]
    server.stop
  end
end
