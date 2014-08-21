request = require 'request'
mm = require 'musicmetadata'

database =
  update: (callback) ->
    _database = database.read()
    id    = _database.userId
    token = _database.token

    if not id or not token
      console.error 'Sync failed because auth is not loaded now.\nTrying to restart sync...'
      setTimeout ->
        database.update()
      , 1000
    else
      request "https://api.vk.com/method/audio.get?owner_id=#{id}&access_token=#{token}&v=#{config.vk.version}", (error, response, body) ->
        if not error and response.statusCode is 200
          json = JSON.parse body
          result = {lastSync: Date.now(), audio: []}

          for j in json.response.items
            result.audio.push {id: j.id, artist: j.artist.replace(/—/, '-'), title: j.title.replace(/—/, '-'), duration: j.duration, isCached: false}

          database.write result

          console.log 'Id\'s sync completed successfully.'
          
          database.cache.get (data) ->
            database.cache.write data
            console.log callback
            callback()
        else
          console.error error

  write: (data) ->
    if fs.existsSync config.file.database
      file = fs.readFileSync config.file.database
      
      if file.length is 0 # check if file exists but empty
        file = {}
      else
        file = JSON.parse file
    else
      file = {}

    for own key, value of data
      file[key] = value
    
    fs.writeFileSync config.file.database, JSON.stringify file

  read: ->
    if fs.existsSync config.file.database
      a = fs.readFileSync config.file.database

      if a.length isnt 0 # check if file exists but empty
        return JSON.parse a
    
    {}

  cache:
    _get: (i, cachedList, result, callback) ->
      a = cachedList[i]
      _meta = a.substr(0, a.length - 4).split ' — '
      artist = _meta[0]
      title  = _meta[1]

      mm fs.createReadStream(config.folder.audio + a), { duration: true }
      .on 'duration', (duration) ->
        result.push {artist: artist, title: title, duration: duration}

        if result.length - 1 is cachedList.length - 1
          callback result
        else
          i++
          database.cache._get i, cachedList, result, callback        

    get: (callback) ->
      cachedList = fs.readdirSync config.folder.audio

      if cachedList.length isnt 0
        database.cache._get 0, cachedList, [], callback
      else
        callback []

    write: (cached) ->
      if cached.length isnt 0
        _database = database.read()
        console.log cached
        for a in _database.audio
          for b in cached
            if a.artist is b.artist and a.title is b.title
              if a.duration is b.duration or a.duration + 1 is b.duration or a.duration - 1 is b.duration
                console.log "“#{a.artist} — #{a.title}” is cached."
                a.isCached = true

        database.write _database

        console.log 'Wrote cached audio to database.'
      else
        console.log 'There\'s no cached audio.'