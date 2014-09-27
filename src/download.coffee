progress = require 'request-progress'

_download = (link, name, id, userInfo, callback) ->
  console.clear()

  path = config.audioFolder + name + '.mp3'

  userInfo[0]++
  userInfo[1] += 2 # Я знаю.

  # Скачивание
  progress request link, ->
    throttle: 100
  .on 'progress', (state) ->
    process.stdout.cursorTo 0, 0

    stripe = ''
    a = process.stdout.columns
    _a = a - 3 # [===>] -> ===
    b = (_a * (state.percent / 100)).toFixed()
    stripe += '['
    stripe += '=' for [1..b]
    stripe += '>'
    stripe += ' ' for [1.._a - b]
    stripe += ']'

    process.stdout.write stripe

    process.stdout.cursorTo 0, 1

    line = "#{(state.received / (1024 * 1000)).toFixed(2)} mb / #{(state.total / (1024 * 1000)).toFixed(2)} mb\n#{state.percent}%\n#{userInfo[0]} из #{userInfo[1]}\n#{name}"

    process.stdout.write line
  .on 'error', (err) ->
    console.error err
  .pipe fs.createWriteStream path
  .on 'error', (err) ->
    console.error err
  .on 'close', (err) ->
    console.clear()

    tag = taglib.tagSync path
    tag.comment = "VK id: #{id}\n\n"
    tag.saveSync()

    console.log "#{name} сохранён."

    callback()

download = (id, name, userInfo, callback) ->
  userId = tmp.userId
  token  = tmp.token

  if not userId or not token
    console.error 'Загрузка песни не удалась, так как авторизация ещё не завершилась.\nПробую перезапустить загрузку...'
    setTimeout ->
      download id, callback
    , 1000
  else
    request "https://api.vk.com/method/audio.getById?audios=#{userId}_#{id}&access_token=#{token}&v=#{config.vk.version}", (error, response, body) ->
      if not error and response.statusCode is 200
        json = JSON.parse body
        j = json.response[0]
        _download j.url, name, id, userInfo, callback
      else
        console.error error