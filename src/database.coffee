request = require 'request'
taglib  = require 'taglib'

database =
  update: (callback) ->
    id    = tmp.userId
    token = tmp.token

    if not id or not token
      console.error 'Синхронизация не удалась из-за того, что авторизация ещё не завершилась.\nПробую запустить синхронизацию ещё раз...'
      setTimeout ->
        database.update()
      , 1000
    else
      console.log 'Скачиваю список песен из ВК...'

      request "https://api.vk.com/method/audio.get?owner_id=#{id}&access_token=#{token}&v=#{config.vk.version}", (error, response, body) ->
        if not error and response.statusCode is 200
          json = JSON.parse body

          tmp.audio = []

          for j in json.response.items
            tmp.audio.push {id: j.id, artist: j.artist.replace(/—/, '-'), title: j.title.replace(/—/, '-'), isCached: false}

          console.log 'Список песен скачан.'

          database.renameDuplicates()
          
          database.cache.get (data) ->
            database.cache.write data
            callback()
        else
          console.error error

  cache:
    _get: (i, cachedList, result, callback) ->
      a = cachedList[i]
      _meta = a.substr(0, a.length - 4).split ' — '
      artist = _meta[0]
      title  = _meta[1]

      path = config.audioFolder + a

      tag = taglib.tagSync path

      item = {artist: artist, title: title}
      item.id = if tag.comment then tag.comment.replace(/\n\n.*/, '').replace(/VK id: ([0-9]+)/, '$1') else ''

      result.push item

      if result.length is cachedList.length
        callback result
      else
        database.cache._get ++i, cachedList, result, callback

    get: (callback) ->
      cachedList = fs.readdirSync config.audioFolder

      for key, value of cachedList # удалить
        cachedList.splice key, 1 if value is 'data.json'

      if cachedList.length isnt 0
        database.cache._get 0, cachedList, [], callback
      else
        callback []

    write: (cached) ->
      if cached.length isnt 0
        for a in tmp.audio
          for b in cached
            if a.artist is b.artist and a.title is a.title and `a.id == b.id` # Я слишком ленив, чтобы использовать .toString()
              a.isCached = true
              continue;

        console.log 'Уже загруженные песни отмечены и не будут скачиваться повторно.'
      else
        console.log 'Нет загруженных песен.'

  renameDuplicates: ->
    r = /\s\[([0-9]+)\]$/

    for a in tmp.audio
      for b in tmp.audio
        if "#{a.artist} — #{a.title}" is "#{b.artist} — #{b.title}" and a.id isnt b.id
          if b.title.match r # 'name [0]' => 'name [1]'
            b.title = b.title.replace r, (s, p) ->
              i = parseInt p
              i++
              return " [#{i}]"
          else
            b.title += ' [1]'
        continue