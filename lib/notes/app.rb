require 'app'
require_relative 'web'

form =
  "<HTML>
    <body>
      <form>
        <input type="text" name="query"><br>
      </form>
    </body>
</HTML>"

app = Proc.new do |env_hash|
      env_hash['PATH_INFO'] = "/search"
      env_hash.store("QUERY_STRING", "query=array add")
      env_hash["BODY"] = form
      body      =
      [, [form]]
    end


end
