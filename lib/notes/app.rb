require_relative 'web'

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

found =
  '<HTML>
    <body>
    <p> These are the notes you requested </p>
    </body>
</HTML>'

  app = Proc.new do |env_hash|
    if env_hash["QUERY_STRING"]
      env_hash["PATH_INFO"] = "/search"
      env_hash.store("Content-Type", "text/html")
      env_hash.store("Content-Length", found.length)
      [200, env_hash, [found]]
    else
      env_hash["PATH_INFO"] = "/search"
      env_hash.store("Content-Type", "text/html")
      env_hash.store("Content-Length", form.length)
      [200, env_hash, [form]]
    end
  end

server = Notes::Server.new(app, Host: 'localhost', Port:4233)
server.start
server.stop
