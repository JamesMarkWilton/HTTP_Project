require 'minitest'
require 'search_notes'

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
