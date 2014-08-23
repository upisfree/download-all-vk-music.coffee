console = require 'better-console'
prompt  = require 'prompt'

prompt.colors = false
prompt.message = prompt.delimiter = ''
prompt.start()

prompt.get {name: 'folder', description: 'Enter audio folder (with /):'}, (e, result) ->
  if e
    console.error e
  else
    config.audioFolder = result.folder

    if not fs.existsSync config.audioFolder
      fs.mkdir config.audioFolder, (e) ->
        console.error e
      console.log config.audioFolder + ' created.'

    auth ->
      database.update ->
        _downloadAudio 0

_downloadAudio = (i) ->
  if tmp.audio[i].isCached is true
    i++
    _downloadAudio i
  else
    download tmp.audio[i].id, [i, tmp.audio.length], ->
      if i isnt tmp.audio.length - 1
        i++
        _downloadAudio i
      else
        console.log 'All songs downloaded.'