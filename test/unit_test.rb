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
end
