http = require 'http'
fs   = require 'fs'
url  = require 'url'
open = require 'open'

# Open auth page

open 'https://oauth.vk.com/authorize?\
  client_id=4509610&\
  scope=audio,offline&\
  display=page&\
  v=5.24&\
  response_type=token&\
  redirect_uri=http://127.0.0.1:8080/?do=getTokenHtml'

http.createServer (req, res) ->
  query = url.parse(req.url, true).query

  switch query.do
    when 'getToken'
      console.log query.token + '\n' + query.userId

    # Get token from html (this is bad solution)
    when 'getTokenHtml'
      fs.readFile __dirname + '/token.html', (e, html) ->
        if e
          console.log e

        res.writeHead 200, {'Content-Type': 'text/html'}
        res.write html
        res.end()
.listen 8080
