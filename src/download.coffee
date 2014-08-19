progress = require 'request-progress'

_download = (link, name, userInfo, callback) ->
  console.clear()

  # Indicator
  circleState = 0
  circle = setInterval ->
    switch circleState
      when 0
        a = 'O o o'
      when 1
        a = 'o O o'
      when 2
        a = 'o o O'

    process.stdout.cursorTo 0, 0
    process.stdout.write a

    if circleState is 2
      circleState = 0
    else
      circleState++
  , 100

  # Download
  progress request link, ->
    throttle: 100
  .on 'progress', (state) ->
    process.stdout.cursorTo 0, 1

    line = "#{(state.received / (1024 * 1000)).toFixed(2)} mb / #{(state.total / (1024 * 1000)).toFixed(2)} mb\n#{state.percent}%\n#{userInfo[0]} of #{userInfo[1]}\n#{name}"

    process.stdout.write line
  .on 'error', (err) ->
    console.error err
  .pipe fs.createWriteStream config.folder.audio + "#{name}.mp3"
  .on 'error', (err) ->
    console.error err
  .on 'close', (err) ->
    console.clear()
    console.log "#{name} saved successful."
    clearInterval circle

    callback()

download = (id, userInfo, callback) ->
  _database = database.read()
  userId = _database.userId
  token  = _database.token

  if not userId or not token
    console.error 'Download song failed because auth is not loaded now.\nTrying to restart download...'
    setTimeout ->
      download id, callback
    , 1000
  else
    request "https://api.vk.com/method/audio.getById?audios=#{userId}_#{id}&access_token=#{token}&v=#{config.vk.version}", (error, response, body) ->
      if not error and response.statusCode is 200
        json = JSON.parse body
        j = json.response[0]
        _download j.url, j.artist.replace(/—/, '-') + ' — ' + j.title.replace(/—/, '-'), userInfo, callback
      else
        console.error error