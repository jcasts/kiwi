$: << "./lib"
require 'kiwi'

class MyApp < Kiwi::App

  mime_types "text/html", "application/json"

  serializers.clear

  serialize 'html' do |data|
    content_type 'text/html'
      <<-STR
<html>
  <head>
  <title>TEST KIWI</title>
  </head>
  <body>
   #{Kiwi::HTMLBuilder.new.html(data)}
  </body>
</html>
      STR
  end


  serialize 'json' do |data|
    content_type 'application/json'
    data.to_json
  end
end


run MyApp.new
