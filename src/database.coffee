request = require 'request'

database =
  update: (id, token) ->
    request "https://api.vk.com/method/audio.get?owner_id=#{id}&access_token=#{token}&v=#{config.vk.version}", (error, response, body) ->
      if not error and response.statusCode is 200
        json = JSON.parse body
        result = {lastSync: Date.now(), audio: []}

        for j in json.response.items
          result.audio.push [j['id'], false]

        fs.writeFileSync config.file.database, JSON.stringify result
      else
        console.error error
      