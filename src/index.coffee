console = require 'better-console'

if not fs.existsSync config.folder.audio
  fs.mkdir config.folder.audio
  console.log config.folder.audio + ' created.'

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

auth ->
  database.update ->
    _downloadAudio 0