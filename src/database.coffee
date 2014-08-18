request = require 'request'

database =
  update: (id, token) ->
    request "https://api.vk.com/method/audio.get?owner_id=#{id}&access_token=#{token}&v=#{config.vk.version}", (error, response, body) ->
      if not error and response.statusCode is 200
        json = JSON.parse body
        result = {lastSync: Date.now(), audio: []}

        for j in json.response.items
          result.audio.push [j['id'], false]

        database.write result
      else
        console.error error
  write: (data) ->
    if fs.existsSync config.file.database
      file = JSON.parse fs.readFileSync config.file.database
    else
      file = {}

    for own key, value of data
      file[key] = value
    
    fs.writeFileSync config.file.database, JSON.stringify file
  read: ->
    if fs.existsSync config.file.database
      JSON.parse fs.readFileSync config.file.database
    else
      false