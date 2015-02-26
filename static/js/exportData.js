// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'ractive_events_keys', 'rv!../ractive/exportDataTemplate', 'geocoder', 'jquery', 'mapbox'], function ( Ractive, events, html, geocoder, $, mapbox) {

	/*var pointIndex;
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



	}*/

	/*var locationsRactive = new Ractive({
      el: 'locations',
      template: html,
      data: {
      	 names: names,
         locations: geoCodedData
      }
    });*/

	var startDate = "20150101";
	var endDate = "20151231";

	for (var pointIndex = 0; pointIndex<points.length; pointIndex++) {
		var point = points[pointIndex];
		var divId = "export"+(pointIndex+1);
		L.mapbox.accessToken = 'pk.eyJ1IjoiZ3VpbHR5c3BhcmsiLCJhIjoiSHFCN3dORSJ9.FEKH5Kb6J5aK7ezNtn9BeQ';
		var map = L.mapbox.map(divId, "guiltyspark.kl48ij2n", { zoomControl: false, attributionControl: false })
		.setView([point[0], point[1]], 14);

		$.ajax({
	        dataType: "json",
	        url: "./crimes/"+point[0]+","+point[1]+","+startDate+","+endDate,
	        async: false,
	        success: function(json) {
	            geojson = json["geojson"]
	            locations = L.mapbox.featureLayer().addTo(map);
	            locations.setGeoJSON(geojson);
	            locations.eachLayer(function(locale) {
			        // Iterate over each marker.
			        var prop = locale.feature.properties;
			        //console.log(locale);

			        locale.setIcon(L.icon({
					  iconUrl: './static/img/'+prop.icon,
					  iconSize: [25, 25],
					  iconAnchor: [25, 25],
					  popupAnchor: [0, -34]
					}));
					//$(locale._icon).addClass('animated fadeIn');
			        //locale.bindPopup(prop.desc);
			    });
	        }
	    });
	}



    


	

});