$LOAD_PATH.unshift File.realdirpath("../../../lib", __FILE__)
require 'search_notes'

$LOAD_PATH.unshift File.realdirpath("../../storage", __FILE__)
require 'data'

require 'erb'
require_relative 'server'

class Notes
  App = Proc.new do |env_hash|
    @notes = env_hash["NOTES"] || DATA

    if env_hash["PATH_INFO"] == "/"
      form = File.read(File.realdirpath("../../storage/forms.html", __FILE__))
      env_hash.store("Content-Type", "text/html")
      env_hash.store("Content-Length", form.length)
      [200, env_hash, [form]]

    else
      selectors = env_hash["QUERY_STRING"].sub("query=", "") if env_hash["QUERY_STRING"]

      @notes = SearchNotes.find_notes(@notes, selectors.split("+")) if selectors

      template = File.read(File.realdirpath("../../storage/body.html", __FILE__))
      body = ERB.new(template).result(binding)
      env_hash.store("Content-Type", "text/html")
      env_hash.store("Content-Length", body.length)
      [200, env_hash, [body]]
    end
  end
end
