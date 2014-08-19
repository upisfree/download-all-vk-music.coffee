console = require 'better-console'

auth()

if not fs.statSync config.folder.audio
  fs.mkdir config.folder.audio
  console.log config.folder.audio + ' created.'

_downloadAudio = (db, i) ->
  if db.audio[i].isCached is true
    i++
    _downloadAudio db, i
  else
    download db.audio[i].id, [i++, db.audio.length], ->
      db.audio[i].isCached = true
      database.write db

      if i isnt db.length - 1
        i++
        _downloadAudio db, i

database.update ->
  _database = database.read()

  _downloadAudio _database, 0