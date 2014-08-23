request = require 'request'
mm = require 'musicmetadata'

database =
  update: (callback) ->
    id    = tmp.userId
    token = tmp.token

    if not id or not token
      console.error 'Sync failed because auth is not loaded now.\nTrying to restart sync...'
      setTimeout ->
        database.update()
      , 1000
    else
      request "https://api.vk.com/method/audio.get?owner_id=#{id}&access_token=#{token}&v=#{config.vk.version}", (error, response, body) ->
        if not error and response.statusCode is 200
          json = JSON.parse body

          tmp.audio = []

          for j in json.response.items
            tmp.audio.push {id: j.id, artist: j.artist.replace(/—/, '-'), title: j.title.replace(/—/, '-'), duration: j.duration, isCached: false}

          console.log 'Id\'s sync completed successfully.'
          
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

      stream = fs.createReadStream config.audioFolder + a

      mm stream, { duration: true } 
      .on 'metadata', (meta) ->
        result.push {artist: artist, title: title, duration: meta.duration}

        if result.length is cachedList.length
          callback result
        else
          database.cache._get ++i, cachedList, result, callback
      .on 'done', (e) ->
        if e
          console.error e + "\nError with #{artist} — #{title}.mp3\nTry to delete it and restart."

        #console.log i, result[i]

        stream.destroy()

    get: (callback) ->
      cachedList = fs.readdirSync config.audioFolder

      for key, value of cachedList # remove
        cachedList.splice key, 1 if value is 'data.json'

      if cachedList.length isnt 0
        database.cache._get 0, cachedList, [], callback
      else
        callback []

    write: (cached) ->
      if cached.length isnt 0
        for a in tmp.audio
          for b in cached
            if a.artist is b.artist and a.title is b.title
              if a.duration is b.duration or a.duration + 1 is b.duration or a.duration - 1 is b.duration or b.duration is 0
                #console.log a.duration + ', ' + b.duration
                console.log "“#{a.artist} — #{a.title}” is cached."
                a.isCached = true

        console.log 'Wrote cached audio to database.'
      else
        console.log 'There\'s no cached audio.'