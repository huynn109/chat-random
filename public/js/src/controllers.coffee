HomeCtrl = ($scope, $location) ->
  angular.element('html').css { background: '#F3F3F3' }
  angular.element('.logo').animate
    marginTop: '100px'
    opacity: '1'
  ,
    duration: 750
    complete: ->
      angular.element('.find.btn').fadeIn 300

  angular.element('.find.btn').on 'click', (e) ->
    angular.element('.wave-left, .wave-right').css { display: 'block' }
    angular.element('.wave-left').animate
      left: '0px'
      opacity: '0'
    , duration: 500

    angular.element('.wave-right').animate
      left: '235px'
      opacity: '0'
    , duration: 500

    angular.element('.splash').animate
      opacity: '0'
      background: '#E7E7E7'
    ,
      duration: 1000
      complete: ->
        window.location = '#/chat'
          

ChatCtrl = ($scope) ->
  angular.element('.chat').fadeIn()
  status = 'offline'
  $scope.messages = []
  isTyping = no
  lastPress = undefined

  socket = io.connect '/'
  socket.on 'log', (data) -> $('#status-message').text data.print

  socket.on 'connected', ->
    status = 'online'
    $('#status-message').removeClass 'typing'
    $('#status-message').text 'Connected to someone'
    $scope.messages = []
    $scope.$apply()

  socket.on 'disconnected', ->
    status = 'offline'
    $('#status-message').removeClass 'typing'
    $('#status-message').text 'Stranger has disconnected'

  socket.on 'next', (data) ->
    status = 'nexted'
    $('#status-message').removeClass 'typing'
    $('#status-message').text 'Next initiated by the stranger'

  socket.on 'msg', (data) ->
    appendMessage 'Stranger', data.body
    $scope.$apply()

  socket.on 'typing', ->
    $('#status-message').addClass 'typing'
    $('#status-message').text 'Stranger is typing'

  socket.on 'not typing', ->
    $('#status-message').removeClass 'typing'
    $('#status-message').text ''

  appendMessage = (from, message) ->
    $scope.messages.push { author: from, text: message }
    $('.messages').animate { scrollTop: $('.messages').prop('scrollHeight') }, { queue: false }, 1000

  sendMessage = (message) ->
    unless status is 'offline' or status is 'nexted'
      message = message.trim()
      socket.emit 'msg', { body: message }   if message.length > 0
      $scope.enteredText = ''
      appendMessage 'You', message
      if isTyping
        socket.emit 'not typing'
        isTyping = no

  $('#chat-text-input').keypress (e) ->
    unless e.which is 13
      lastPress = new Date()
      unless isTyping
        isTyping = yes
        socket.emit 'typing'

      setTimeout ->
        now = new Date()
        if (now - 1000) >= lastPress
          socket.emit 'not typing'
          isTyping = no
      , 1000


  $scope.next = -> socket.emit 'next'
  $scope.say = -> sendMessage $scope.enteredText