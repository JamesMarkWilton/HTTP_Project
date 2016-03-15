$LOAD_PATH.unshift File.realdirpath("../../../lib", __FILE__)
require_relative 'server'
require 'notes'

class Notes
  notes = [
    {"description" => "Add 1 to 2",
     "example" => "1 + 2 # => 3"},
    {"description" => "Subtract 5 from 2",
     "example" => "2 - 5 # => -3"},
    {"description" => "Is 1 less than 2",
     "example" => "1 < 2"},
    {"description" => "Is 1 equal to 2",
     "example" => "1 == 2 # => 3"},
    {"description" => "Is 1 greater than 2",
     "example" => "1 > 2"},
    {"description" => "Is 1 less than or equal to 2",
     "example" => "1 <= 2 # => 3"},
    {"description" => "Is 1 greater than or equal to 2",
     "example" => "1 >= 2"},
    {"description" => "Convert 1 to a float",
     "example" => "1.to_f # => 3"},
    {"description" => "Concatenate two arrays",
     "example" => "[1, 2] + [2, 3]"},
    {"description" => "Remove elements in second array from first",
     "example" => "[1, 2, 4] - [2, 3] # => [1, 4]"},
    {"description" => "Access an element in an array by its index",
     "example" =>  "[\"a\",\"b\",\"c\"][0]"},
    {"description" => "Find out how big the array is",
     "example" => "[\"a\",\"b\"].length # => 2"}
  ]

  App = Proc.new do |env_hash|
    found = env_hash[:NOTES] || notes

    if env_hash[:QUERY_STRING]
      selectors = env_hash[:QUERY_STRING].tr("+", " ").tr("=", " ").split(" ")
      selectors.delete_at(0)
      found = find_notes(found, selectors)

      list = []
      if !found.empty?
        found.each do |body_line|
          list << "<li>#{body_line['description']}   #{body_line['example']}</li>"
        end
      else
        list << "<li>Your search yielded no results.</li>"
        list << "<li>Please try again!.</li>"
      end

      body = "<HTML><body><ul>#{list.join}</ul></body></HTML>"
      env_hash["PATH_INFO"] = "/search"
      env_hash.store("Content-Type", "text/html")
      env_hash.store("Content-Length", body.length)
      [200, env_hash, [body]]
    else
      form =
        '<HTML>
          <body>
            <form>
              <form action="action_page.php" method="get">
              <p><input type="text" name="query"><br>Search</p>
              <p><input type="submit" value="Submit"></p>
            </form>
          </body>
        </HTML>'

      env_hash["PATH_INFO"] = "/search"
      env_hash.store("Content-Type", "text/html")
      env_hash.store("Content-Length", form.length)
      [200, env_hash, [form]]
    end
  end
end
