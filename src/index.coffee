console = require 'better-console'

auth()

if not fs.stat config.folder.audio
  fs.mkdir config.folder.audio

database.update global.__userId, global.__token

#download 299652493, __userId, __token