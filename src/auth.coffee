http = require 'http'
fs   = require 'fs'
url  = require 'url'
open = require 'open'

# Открываем страницу авторизации
auth = (callback) ->
  if not tmp.userId or not tmp.token
    open "https://oauth.vk.com/authorize?\
      client_id=#{config.vk.appId}&\
      scope=#{config.vk.permissions}&\
      display=page&\
      v=#{config.vk.version}&\
      response_type=token&\
      redirect_uri=http://127.0.0.1:8080/?do=getTokenHtml"

    http.createServer (req, res) ->
      query = url.parse(req.url, true).query

      switch query.do
        when 'getToken'
          tmp.userId = query.userId
          tmp.token  = query.token

          console.log 'Авторизация прошла успешно.'

          callback()

          res.end()

        # Получаем токен из html (да, плохое решение (или говнокод (да, это говнокод)))
        when 'getTokenHtml'
          fs.readFile __dirname + '/token.html', (e, html) ->
            if e
              console.error e

            res.writeHead 200, {'Content-Type': 'text/html'}
            res.write html
            res.end()
    .listen 8080