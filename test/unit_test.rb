require 'minitest'
require 'notes/server'
require 'stringio'
require 'notes'

class ServerTest < Minitest::Test
  def test_parses_request_into_env_hash
    socket = StringIO.new("GPPD /path HTTP/1.1\r\nHost: hostname:3453\r\nContent-Type: text/html\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "GPPD",          env["REQUEST_METHOD"]
    assert_equal "/path",         env["PATH_INFO"]
    assert_equal "text/html",     env["CONTENT_TYPE"]
    assert_equal "hostname:3453", env["HTTP_HOST"]
  end

  def test_does_not_read_past_last_char_of_request
    socket = StringIO.new("GPPD /path HTTP/1.1\r\nHost: hostname:3453\r\nContent-Type: text/html\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "HI!", env["rack.input"].read
    assert_equal nil,   env["rack.input"].read[4]
  end

  def test_pulls_out_query_string_from_path_if_there_is_one
    socket = StringIO.new("GPPD /path?query=%20array HTTP/1.1\r\nHost: hostname:3453\r\nContent-Type: text/html\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "/path",          env["PATH_INFO"]
    assert_equal "query=%20array", env["QUERY_STRING"]

    socket = StringIO.new("GPPD /path HTTP/1.1\r\nHost: hostname:3453\r\nContent-Type: text/html\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "/path", env["PATH_INFO"]
    assert_equal nil,     env["QUERY_STRING"]
  end


  def test_writes_a_response_the_browser
    response = [200, {Head: "1"}, ["HI!"]]
    socket = StringIO.new
    Notes::Server.write_response(response, socket)

    assert_equal "HTTP/1.1 200\r\nHead: 1\r\n\r\nHI!", socket.string
  end
end

class NotesTest < Minitest::Test

  def test_you_can_search_the_notes
    note = [{"description" => "one", "example" => "1"},
            {"description" => "two", "example" => "2"},
            {"description" => "three", "example" => "3"}]
    selectors = ["one"]
    assert_equal ["description" => "one", "example" => "1"], find_notes(note, selectors)

    selectors = ["2"]
    assert_equal [{"description" => "two", "example" => "2"}], find_notes(note, selectors)
  end

  def test_search_is_case_insensitive
    note = [{"description" => "one", "example" => "1"},
            {"description" => "two", "example" => "2"},
            {"description" => "three", "example" => "3"}]

    selectors = ["ONE"]
    assert_equal [{"description" => "one", "example" => "1"}], find_notes(note, selectors)
  end

  def test_no_selector_returns_all_notes
    note = ["a", "b", "c"]
    selectors = []
    assert_equal ["a", "b", "c"], find_notes(note, selectors)
  end

  def test_you_can_search_with_successive_filters
    note = [{"description" => "one", "example" => "1"},
            {"description" => "one, two", "example" => "1, 2"},
            {"description" => "one, two, three", "example" => "1, 2, 3"}]

    selectors = ["ONE", "two", "three"]
    assert_equal [{"description" => "one, two, three", "example" => "1, 2, 3"}], find_notes(note, selectors)
  end

  def test_you_can_search_for_hidden_data
    note = [{"description" => "Add 1 to 2", "example" => "1 + 2 #=> 3", "other_searches" => "plus + sum"}]

    selectors = ["plus"]
    assert_equal [{"description" => "Add 1 to 2", "example" => "1 + 2 #=> 3", "other_searches" => "plus + sum"}], find_notes(note, selectors)
  end

end
