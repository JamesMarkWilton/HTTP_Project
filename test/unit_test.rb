require 'minitest'
require 'notes/web'
require 'stringio'

class WebTest < Minitest::Test
  def test_makes_a_hash_of_the_request_data
    server = Notes::Web.new("some block", Host: "localhost", Port: 9294)
    socket = StringIO.new("Get HTTP/1.1\r\nOne: 1\r\nTwo: 2\r\n\r\n")
    env = server.parse_request(socket)

    assert_equal "Get HTTP/1.1", env["Path_Info"]
    assert_equal "1", env["One"]
    assert_equal "", env["body"]
    server.stop
  end
end
