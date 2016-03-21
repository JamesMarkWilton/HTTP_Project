require 'notes/server'
require 'net/http'
require 'open3'

class NotesAcceptanceTest < Minitest::Test
  def test_notes_app_runs
    notes_program = File.expand_path('../../bin/notes', __FILE__)
    output = Open3.capture3(notes_program)
    assert_match(/.*float.*1\.to_f/, output[0])

    output = Open3.capture3(notes_program, "-h")
    assert_match(/Purpose.*/, output[0])
  end
end
