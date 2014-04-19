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
	
	$scope.remove=function(photo){ 
		var index=$scope.photos.indexOf(photo)
		$scope.photos.splice(index, 1);  
		$scope.socket.emit('array new', photo);
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
		//alert(photo.id);
		$(".toggle").fadeOut(2000, function(){
			var currentIndex = $scope.photos.length, temporaryValue, randomIndex;
			// While there remain elements to shuffle...
			while (0 !== currentIndex) {

				// Pick a remaining element...
				randomIndex = Math.floor(Math.random() * currentIndex);
				currentIndex -= 1;

				// And swap it with the current element.
				temporaryValue = $scope.photos[currentIndex];
				$scope.photos[currentIndex] = $scope.photos[randomIndex];
				$scope.photos[randomIndex] = temporaryValue;
			}

			$scope.$apply();
			$(".toggle").delay(3000).fadeIn(2000);
		});
	});

	$scope.socket.on('reload', function() {
		window.location.reload();
	})

}