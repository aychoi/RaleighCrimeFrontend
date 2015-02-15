// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'ractive_events_keys', 'rv!../ractive/searchbarTemplate', 'geocoder', 'map'], function ( Ractive, events, html, geocoder, map) {

    var searchRactive = new Ractive({
      el: 'searchContainer',
      template: html,
      data: {
        searchquery: ""
      }
    });

    /*searchRactive.observe('searchquery', function(newValue, oldValue, keypath) {
    	console.log(newValue);
    });*/
	searchRactive.on( 'submit', function( event, address )  {
	  	geocoder.geocode( { 'address': address}, function(results, status) {
	    if (status == google.maps.GeocoderStatus.OK) {
	      /*map.setCenter(results[0].geometry.location);
	      var marker = new google.maps.Marker({
	          map: map,
	          position: results[0].geometry.location
	      });*/
	  	  var newlatlng = { "lat": results[0].geometry.location.k, "lng": results[0].geometry.location.D};
	  	  console.log(newlatlng);
	  	  map.setView(newlatlng, 16);
	    } else {
	      alert('Geocode was not successful for the following reason: ' + status);
	    }
	  });
	});

	

	
    return searchRactive;

});
