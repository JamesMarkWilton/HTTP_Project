require 'minitest'
require 'notes/web'
require 'stringio'

class UnitTest < Minitest::Test
  def test_parses_into_env_hash
    request = ["GPPD /path HTTP/1.1\r\n",
              "Content-Type: text/html\r\n",
              "Content-length: 3\r\n",
              "\r\n"
              ]
    env = Notes::Web.parse_request(request)

    assert_equal "GPPD", env["REQUEST_TYPE"]
    assert_equal "text/html", env["CONTENT_TYPE"]
  end

  def test_it_does_not_read_past_last_char
    socket = StringIO.new("GPPD /path HTTP/1.1\r\nContent-Type: text/html\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Web.get_and_parse(socket)

    assert_equal "HI!", env["BODY"]
    assert_equal nil, env["BODY"][4]
  end

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
