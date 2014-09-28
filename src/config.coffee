config =
  audioFolder: __dirname + '/audio/'
  vk:
    appId: 4509610
    permissions: 'audio,offline'
    version: 5.24

tmp = {}
fileNameRegEx = /[\/\?<>\\:\*\|":\x00-\x1f\x80-\x9f]/g