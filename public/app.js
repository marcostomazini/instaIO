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
		$scope.$apply(function(scope){			
			scope.photos.push(photo);			
		});
	});

	$scope.socket.on('reload', function() {
		window.location.reload();
	})

}