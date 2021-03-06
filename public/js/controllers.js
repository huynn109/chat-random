// Generated by CoffeeScript 1.6.3
var ChatCtrl, HomeCtrl;

HomeCtrl = function($scope, $location) {
  angular.element('html').css({
    background: '#F3F3F3'
  });
  angular.element('.logo').animate({
    marginTop: '100px',
    opacity: '1'
  }, {
    duration: 750,
    complete: function() {
      return angular.element('.find.btn').fadeIn(300);
    }
  });
  return angular.element('.find.btn').on('click', function(e) {
    angular.element('.wave-left, .wave-right').css({
      display: 'block'
    });
    angular.element('.wave-left').animate({
      left: '0px',
      opacity: '0'
    }, {
      duration: 500
    });
    angular.element('.wave-right').animate({
      left: '235px',
      opacity: '0'
    }, {
      duration: 500
    });
    return angular.element('.splash').animate({
      opacity: '0',
      background: '#E7E7E7'
    }, {
      duration: 1000,
      complete: function() {
        return window.location = '#/chat';
      }
    });
  });
};

ChatCtrl = function($scope) {
  var appendMessage, isTyping, lastPress, sendMessage, socket, status;
  angular.element('.chat').fadeIn();
  status = 'offline';
  $scope.messages = [];
  isTyping = false;
  lastPress = void 0;
  socket = io.connect('/');
  socket.on('log', function(data) {
    return $('#status-message').text(data.print);
  });
  socket.on('connected', function() {
    status = 'online';
    $('#status-message').removeClass('typing');
    $('#status-message').text('Connected to someone');
    $scope.messages = [];
    return $scope.$apply();
  });
  socket.on('disconnected', function() {
    status = 'offline';
    $('#status-message').removeClass('typing');
    return $('#status-message').text('Stranger has disconnected');
  });
  socket.on('next', function(data) {
    status = 'nexted';
    $('#status-message').removeClass('typing');
    return $('#status-message').text('Next initiated by the stranger');
  });
  socket.on('msg', function(data) {
    appendMessage('Stranger', data.body);
    return $scope.$apply();
  });
  socket.on('typing', function() {
    $('#status-message').addClass('typing');
    return $('#status-message').text('Stranger is typing');
  });
  socket.on('not typing', function() {
    $('#status-message').removeClass('typing');
    return $('#status-message').text('');
  });
  appendMessage = function(from, message) {
    $scope.messages.push({
      author: from,
      text: message
    });
    return $('.messages').animate({
      scrollTop: $('.messages').prop('scrollHeight')
    }, {
      queue: false
    }, 1000);
  };
  sendMessage = function(message) {
    if (!(status === 'offline' || status === 'nexted')) {
      message = message.trim();
      if (message.length > 0) {
        socket.emit('msg', {
          body: message
        });
      }
      $scope.enteredText = '';
      appendMessage('You', message);
      if (isTyping) {
        socket.emit('not typing');
        return isTyping = false;
      }
    }
  };
  $('#chat-text-input').keypress(function(e) {
    if (e.which !== 13) {
      lastPress = new Date();
      if (!isTyping) {
        isTyping = true;
        socket.emit('typing');
      }
      return setTimeout(function() {
        var now;
        now = new Date();
        if ((now - 1000) >= lastPress) {
          socket.emit('not typing');
          return isTyping = false;
        }
      }, 1000);
    }
  });
  $scope.next = function() {
    return socket.emit('next');
  };
  return $scope.say = function() {
    return sendMessage($scope.enteredText);
  };
};
