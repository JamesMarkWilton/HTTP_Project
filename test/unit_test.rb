require 'minitest'
require 'notes/web'
require 'stringio'

class WebTest < Minitest::Test
  def test_makes_a_hash_of_the_request_data
    server = Notes::Web.new("some block", Host: "localhost", Port: 9294)
    request = ["Get HTTP/1.1\r\n", "One: 1\r\n", "Two: 2\r\n", "\r\n"]
    env = {}
    #Derreck's Idea For Better or Worse from 2011 Josh Cheek article:
    #stdin = MockStream.new('5')
    #stdout = MockStream.new
    #assert_equal 5, UserPrompter.integer(stdin, stdout)
    #assert_equal '', stdin.read
    #assert_equal 'Enter an integer: ', stdout.string
    server.parse_request(request, env)
    #test_input = StringIO.new << ourCode
    assert_equal "Get HTTP/1.1", env["Path_Info"]
    assert_equal "1", env["headers"]["One"]
    assert_equal nil, env["body"]
    server.stop
  end
end
