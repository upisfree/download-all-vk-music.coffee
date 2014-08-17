progress = require 'request-progress'

_download = (link) ->
  # Clear console
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

    line = "#{state.received} / #{state.total}\n#{state.percent}%\n#{link}"

    process.stdout.write line
  .on 'error', (err) ->
    console.error err
  .pipe fs.createWriteStream __dirname + '/test.mp3'
  .on 'error', (err) ->
    console.error err
  .on 'close', (err) ->
    console.clear()
    console.info 'Saved!'
    clearInterval circle

download = (id, userId, token) ->
  request "https://api.vk.com/method/audio.getById?audios=#{userId}_#{id}&access_token=#{token}&v=#{config.vk.version}", (error, response, body) ->
    if not error and response.statusCode is 200
      json = JSON.parse body
      _download json.response[0].url 