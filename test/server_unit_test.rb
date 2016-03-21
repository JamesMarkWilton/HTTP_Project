require 'minitest'
require 'notes/server'
require 'notes/app'
require 'stringio'

class ServerTest < Minitest::Test
  def test_parses_request_into_env_hash
    socket = StringIO.new("G / H\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "G", env["REQUEST_METHOD"]
    assert_equal "/", env["PATH_INFO"]
    assert_equal "H", env["SERVER_PROTOCOL"]
    assert_equal "3", env["CONTENT_LENGTH"]
    assert_equal "HI!", env["BODY"][0]
  end

  def test_does_not_read_past_last_char_of_request
    socket = StringIO.new("G /search H\r\nHost: l:p\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "HI!", env["BODY"][0]
    assert_equal nil, env["BODY"][1]
  end

  def test_pulls_out_query_string_from_path_if_there_is_one
    socket = StringIO.new("G /search?query=array H\r\nHost: l:p\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "/search", env["PATH_INFO"]
    assert_equal "query=array", env["QUERY_STRING"]

    socket = StringIO.new("G / H\r\nHost: l:p\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "/", env["PATH_INFO"]
    assert_equal nil, env["QUERY_STRING"]
  end

  def test_writes_a_response_the_browser
    response = [200, {Head: "1"}, ["HI!"]]
    socket = StringIO.new
    Notes::Server.write_response(response, socket)

    assert_equal "HTTP/1.1 200\r\nHead: 1\r\n\r\nHI!", socket.string
  end

  def test_app_returns_response_array
    response = Notes::App::RUN.call("PATH_INFO" => "/")

    assert_equal 200,        response[0]
    assert_match(/<HTML>.*/, response[2][0])
  end

  def test_app_returns_searched_notes
    response = Notes::App::RUN.call("PATH_INFO" => "/search",
                                    "QUERY_STRING" => "query=1",
                                    "BODY" => ["description=%0D%0ANumber",
                                               "example=%0D%0A1"])

    assert_match(/.*Number.*/, response[2][0])
    refute_match(/.*Letter.*/, response[2][0])
  end

  def test_app_returns_css_stylesheet
    response = Notes::App::RUN.call("PATH_INFO" => "/notes.css")

    assert_equal "text/css", response[1]["Content-Type"]
  end
end
