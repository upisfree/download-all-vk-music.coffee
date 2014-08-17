progress = require 'request-progress'
console = require 'better-console'

download = () ->
  # Clear console
  console.clear()

  # Indicator
  circleState = 0
  circle = setInterval ->
    switch circleState
      when 0
        a = 'O o o'
      when 1
        a = 'o O o'
      when 2
        a = 'o o O'

    process.stdout.cursorTo 0, 0
    process.stdout.write a

    if circleState is 2
      circleState = 0
    else
      circleState++
  , 100

  # Download
  progress request 'https://psv4.vk.me/c536620/u223436253/audios/bc68997bb6ca.mp3' , ->
    throttle: 100
  .on 'progress', (state) ->
    process.stdout.cursorTo 0, 1

    line = "#{state.received} / #{state.total}\n#{state.percent}%"

    process.stdout.write line
  .on 'error', (err) ->
    console.log err
  .pipe fs.createWriteStream __dirname + '/test.mp3'
  .on 'error', (err) ->
    console.log err
  .on 'close', (err) ->
    console.clear()
    console.log 'Saved!'
    clearInterval circle