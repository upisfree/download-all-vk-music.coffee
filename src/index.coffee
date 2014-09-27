console = require 'better-console'
prompt  = require 'prompt'

prompt.colors = false
prompt.message = prompt.delimiter = ''
prompt.start()

prompt.get {name: 'folder', description: 'Введи папку, куда сохранять песни (с / или \\):'}, (e, result) ->
  if e
    console.error e
  else
    config.audioFolder = result.folder

    if not fs.existsSync config.audioFolder
      fs.mkdir config.audioFolder, (e) ->
        console.error e
      console.log config.audioFolder + ' создана.'

    auth ->
      database.update ->
        _downloadAudio 0

_downloadAudio = (i) ->
  if tmp.audio[i].isCached is true
    c = "#{tmp.audio[i].artist} — #{tmp.audio[i].title}"
    quotes = if c.match(/([a-z])/gi) > c.match(/([а-яё])/gi) then ['“', '”'] else ['«', '»']
    console.log "#{quotes[0]}#{c}#{quotes[1]} уже загружена."
    i++
    _downloadAudio i
  else
    download tmp.audio[i].id, tmp.audio[i].artist.replace(/—/, '-') + ' — ' + tmp.audio[i].title.replace(/—/, '-'), [i, tmp.audio.length], ->
      if i isnt tmp.audio.length - 1
        i++
        _downloadAudio i
      else
        console.log 'Все песни загружены.'