require 'minitest'
require 'notes/web'
require 'stringio'

class UnitTest < Minitest::Test
  def test_parses_request_into_env_hash
    request = ["GPPD /path HTTP/1.1\r\n",
               "Host: hostname:port\r\n",
              "Content-Type: text/html\r\n",
              "Content-length: 3\r\n",
              "\r\n"
              ]
    env = Notes::Web.parse_request(request)

    assert_equal "GPPD", env["REQUEST_METHOD"]
    assert_equal "text/html", env["CONTENT_TYPE"]
  end

  def test_does_not_read_past_last_char_of_request
    socket = StringIO.new("GPPD /path HTTP/1.1\r\nHost: hostname:3453:Content-Type: text/html\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Web.get_request(socket)

    assert_equal "HI!", env["rack.input"].read
    assert_equal nil, env["rack.input"].read[4]
  end
end
