function PhotoCtrl($scope) {

	$scope.photos = [];

	$scope.$watch('photo', function() { 
		$scope.isoTime = new Date(parseInt($scope.photo.created_time)*1000).toISOString()
	}, true);

	$scope.socket = io.connect(window.location.protocol + "//" + window.location.host);

	$scope.byCreatedTime = function(photo) {		
  		return -1* parseInt(photo.created_time);
  	}

	$scope.socket.on('bootstrap', function(photos) {
		//console.log('bootstrap', photos);
		$scope.$apply(function(scope) {
			scope.photos = photos;
		});
	});	

	$scope.socket.on('new', function(photo) {
		//console.log('new', photo);	
		//$scope.photos.pop();
		//$scope.photos.slice(1, -1);
		$scope.photos.shift();
		$scope.$apply(function(scope){			
			scope.photos.push(photo);			
		});
	});
	
	$scope.socket.on('random', function(photo) {
		//console.log('new', photo);	
		//$scope.photos.pop();
		//$scope.photos.slice(1, -1);
		$scope.photos.shift();
		shuffle($scope.photos);		
		$scope.$apply(function(scope){			
			scope.photos.push(photo);			
		});
	});

	$scope.socket.on('reload', function() {
		window.location.reload();
	})

}

function shuffle(array) {
  var currentIndex = array.length, temporaryValue, randomIndex;

  // While there remain elements to shuffle...
  while (0 !== currentIndex) {

    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }

  return array;
}