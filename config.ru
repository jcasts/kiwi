$: << "./lib"
require 'kiwi'

class MyApp < Kiwi::App

  serialize 'text/html' do |data|
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


  serialize 'text/json', 'application/json' do |data|
    data.to_json
  end
end


run MyApp.new
