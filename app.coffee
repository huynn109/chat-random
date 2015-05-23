
#
# Module dependencies
#

express = require 'express'
app = express()
server = require('http').createServer app
io = require('socket.io').listen server
sanitize = require('validator').sanitize

# all environments
app.set 'port', process.env.PORT or 3000
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use express.favicon("#{__dirname}/public/favicon.ico")
app.use express.logger('dev')
app.use app.router
app.use require('less-middleware')({ src: "#{__dirname}/public" })
app.use express.static("#{__dirname}/public")

# development only
if 'development' is app.get 'env'
  app.use express.errorHandler()

# routes
app.get '/', (req, res) ->
  res.render 'index', { title: 'Stranger Chat' }

# socket.io logic
seekingUsers = []

findStranger = (socket) ->
  if seekingUsers.length > 1
    len = seekingUsers.length
    stranger = seekingUsers[ Math.floor(Math.random() * len) ]
    if socket is stranger  then findStranger socket  else return stranger

removePartner = (user) ->
  user.set 'partner', undefined

initSearch = (socket) ->
  stranger = findStranger socket
  if stranger?
    socket.set 'partner', stranger
    stranger.set 'partner', socket
    deleteFromList socket, stranger
    socket.emit 'connected'
    stranger.emit 'connected'
  else
    socket.emit 'log', { print: 'Waiting for stranger...' }

addToList = (user) ->
  seekingUsers.push user
  initSearch user

deleteFromList = (users...) ->
  for user in users
    seekingUsers.splice  seekingUsers.indexOf(user), 1

io.sockets.on 'connection', (socket) ->
  addToList socket

  socket.on 'next', (data) ->
    socket.get 'partner', (err, stranger) ->
      throw err if err
      if stranger
        stranger.emit 'next'
        removePartner stranger
        removePartner socket
        setTimeout ->
          addToList stranger
        , 3000
        addToList socket
      else
        removePartner socket
        socket.emit 'log', { print: 'You have no companion, please wait' }

  socket.on 'msg', (data) ->
    socket.get 'partner', (err, stranger) ->
      throw err if err
      message = sanitize(data.body).trim()
      message = sanitize(message).xss()
      message = message.slice 0, 240   if message.length > 240
      stranger.emit 'msg', { body: message }   if stranger and message.length > 0

  socket.on 'typing', (data) ->
    socket.get 'partner', (err, stranger) ->
      throw err if err
      stranger.emit 'typing'   if stranger

  socket.on 'not typing', (data) ->
    socket.get 'partner', (err, stranger) ->
      throw err if err
      stranger.emit 'not typing'   if stranger

  socket.on 'disconnect', ->
    socket.get 'partner', (err, stranger) ->
      throw err if err
      if stranger
        stranger.emit 'disconnected'
        removePartner stranger
        addToList stranger
      else
        deleteFromList socket

# server init
server.listen app.get('port'), ->
  console.log "Express is listening on port #{ app.get('port') }"