$LOAD_PATH.unshift File.realdirpath("../../../lib", __FILE__)
require 'search_notes'

# This is where I am storing the default notes in the Constant DATA
$LOAD_PATH.unshift File.realdirpath("../../storage", __FILE__)
require 'data'

require 'erb'
require_relative 'server'

class Notes
  class App
    RUN = Proc.new do |env_hash|
      @notes = env_hash["NOTES"] || DATA

      case env_hash["PATH_INFO"]
      when "/notes/new"
        new_note(env_hash)
      when "/search"
        search(env_hash)
      when [/.*\/notes.css/]
        css_style(env_hash)
      else
        root(env_hash)
      end
    end

    def self.root(env_hash)
      form = File.read(File.realdirpath("../../storage/search_form.html", __FILE__))
      env_hash.store("Content-Type", "text/html")
      env_hash.store("Content-Length", form.length)
      [200, env_hash, [form]]
    end

    def self.new_note(env_hash)
      form = File.read(File.realdirpath("../../storage/new_notes_form.html", __FILE__))
      env_hash.store("Content-Type", "text/html")
      env_hash.store("Content-Length", form.length)
      [200, env_hash, [form]]
    end

    def self.css_style(env_hash)
      stylesheet = File.read(File.realdirpath("../../storage/notes.css", __FILE__))
      env_hash.store("Content-Type", "text/css")
      env_hash.store("Content-Length", stylesheet.length)
      [200, env_hash, [stylesheet]]
    end

    def self.search(env_hash)
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
