function PhotoCtrl($scope) {

	$scope.photos = [];
	
	/*$scope.$watch('photos', function() { 
		//alert($scope.photos[0].created_time);
		$scope.isoTime = new Date(parseInt($scope.photos[0].created_time)*1000).toISOString()
		alert($scope.isoTime);
	}, true);*/

	$scope.socket = io.connect(window.location.protocol + "//" + window.location.host);

	$scope.byCreatedTime = function(photo) {		
  		return -1* parseInt(photo.created_time);
  	}
	
	$scope.linkInstagram = function(photo) {		
  		return "http://instagram.com/" + photo.user.username;
  	}

	$scope.socket.on('bootstrap', function(photos) {
		$scope.$apply(function(scope) {
			scope.photos = photos;			
		});
	});	

	$scope.socket.on('new', function(photo) {
		console.log('new', photo);	
		$scope.photos.shift();
		$scope.$apply(function(scope){			
			scope.photos.push(photo);			
		});
	});
	
	$scope.socket.on('one call', function(photo) {
		$(".toggle").fadeOut(2000, function(){
			shuffle($scope.photos);		
			$scope.$apply(function(scope){			
				scope.photos.push(photo);								
			});				
			$(".toggle").delay(3000).fadeIn(2000);
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