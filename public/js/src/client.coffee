angular.module('chat', [])
  .config(['$routeProvider', ($routeProvider) ->
    $routeProvider
      .when('/', { templateUrl: 'partials/home.html', controller: HomeCtrl })
      .when('/chat', { templateUrl: 'partials/chat.html', controller: ChatCtrl })
      .otherwise({ redirectTo: '/' })
  ])