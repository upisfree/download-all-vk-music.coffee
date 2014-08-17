console = require 'better-console'

if fs.existsSync config.file.auth
  a = fs.readFileSync config.file.auth, 'utf-8'
  a = a.split '\n'
    #a = data.split '\n'
  global.__userId = a[0]
  global.__token  = a[1]
else
  auth()

#database.update __userId, __token

download 299652493, __userId, __token