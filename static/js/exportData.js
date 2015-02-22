// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'ractive_events_keys', 'rv!../ractive/exportDataTemplate', 'geocoder', 'jquery'], function ( Ractive, events, html, geocoder, $) {

	var pointIndex;
	var geoCodedData = []
	for (pointIndex in points) {
		var point = points[pointIndex];
		var latlng = new google.maps.LatLng(point[0], point[1]);
		geocoder.geocode( { 'latLng': latlng }, function(results, status) {
		    if (status == google.maps.GeocoderStatus.OK) {
		    	if (results[1]) {
		    		geoCodedData.push(results[1].formatted_address);
		    	}  
		    }
	  });



	}

	var locationsRactive = new Ractive({
      el: 'locations',
      template: html,
      data: {
         locations: geoCodedData
      }
    });

	

});