require "nokogiri"

module SportNginWatir
  class Browser

    def text
      doc = Nokogiri::HTML(body(:index => 0).html)
      doc.css("script").remove # encoding bug in older libxml?

      doc.inner_text
    end

  end # Browser
end # SportNginWatir
