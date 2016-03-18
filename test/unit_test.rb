require 'minitest'
require 'notes/server'
require 'notes/app'
require 'stringio'
require 'search_notes'

class ServerTest < Minitest::Test
  def test_parses_request_into_env_hash
    socket = StringIO.new("G / H\r\nHost: l:p\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "G", env["REQUEST_METHOD"]
    assert_equal "/", env["PATH_INFO"]
  end

  def test_does_not_read_past_last_char_of_request
    socket = StringIO.new("G /search H\r\nHost: l:p\r\nContent-length: 3\r\n\r\nHI!")
    env = Notes::Server.get_and_parse_request socket

    assert_equal "HI!", env["rack.input"].read
    assert_equal nil, env["rack.input"].read[4]
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
    response = Notes::App.call("PATH_INFO" => "/")
    assert_equal 200,        response[0]
    assert_match(/<HTML>.*/, response[2][0])
  end

  def test_app_returns_searched_notes
    response = Notes::App.call("QUERY_STRING" => "query=1", "PATH_INFO" => "/search",
                               "NOTES" => [{"description" => "Number", "example" => "1"},
                                           {"description" => "Letter", "example" => "A"}])

    assert_match(/.*Number.*/, response[2][0])
    refute_match(/.*Letter.*/, response[2][0])

    response = Notes::App.call("PATH_INFO" => "/",
                               "NOTES" => [{"description" => "Number", "example" => "1"},
                                           {"description" => "Letter", "example" => "A"}])

    refute_match(/.*Number.*/, response[2][0])
    refute_match(/.*Letter.*/, response[2][0])
  end
end

class NotesTest < Minitest::Test
  def test_you_can_search_the_notes
    note = [{"description" => "one", "example" => "1"},
            {"description" => "two", "example" => "2"},
            {"description" => "three", "example" => "3"}]
    selectors = ["one"]
    assert_equal ["description" => "one", "example" => "1"],
                 SearchNotes.find_notes(note, selectors)

    selectors = ["2"]
    assert_equal [{"description" => "two", "example" => "2"}],
                 SearchNotes.find_notes(note, selectors)
  end

  def test_search_is_case_insensitive
    note = [{"description" => "one", "example" => "1"},
            {"description" => "two", "example" => "2"},
            {"description" => "three", "example" => "3"}]

    selectors = ["ONE"]
    assert_equal [{"description" => "one", "example" => "1"}],
                 SearchNotes.find_notes(note, selectors)
  end

  def test_no_selector_returns_all_notes
    note = ["a", "b", "c"]
    selectors = []
    assert_equal ["a", "b", "c"], SearchNotes.find_notes(note, selectors)
  end

  def test_you_can_search_with_successive_filters
    note = [{"description" => "one", "example" => "1"},
            {"description" => "one, two", "example" => "1, 2"},
            {"description" => "one, two, three", "example" => "1, 2, 3"}]

    selectors = ["ONE", "two", "three"]
    assert_equal [{"description" => "one, two, three", "example" => "1, 2, 3"}],
                 SearchNotes.find_notes(note, selectors)
  end

  def test_you_can_search_for_hidden_data
    note = [{"description" => "Add 1 to 2", "example" => "1 + 2 #=> 3"}]

    selectors = ["plus"]
    assert_equal [{"description" => "Add 1 to 2", "example" => "1 + 2 #=> 3"}],
                 SearchNotes.find_notes(note, selectors)
  end
end
