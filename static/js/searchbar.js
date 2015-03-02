// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'ractive_events_keys', 'rv!../ractive/searchbarTemplate', 'geocoder', 'map', 'recentSearches', 'crimeIndex', 'summary', 'jquery', 'jqueryui', 'velocity', 'drag_drop'], function ( Ractive, events, html, geocoder, map, recentSearchesRactive, crimeIndexRactive, summaryRactive, $, jqueryui, Velocity, drag_drop) {

	animationID = 0;
	locations = L.mapbox.featureLayer().addTo(map);
	circleLayer = L.mapbox.featureLayer().addTo(map);
	lastSearch = undefined;

    var searchRactive = new Ractive({
      el: 'searchContainer',
      template: html,
      data: {
        searchquery: "",
        partialMatches: undefined
      }
    });

    $(function() {
	    $( "#draggableButton" ).draggable();
	  });


    
    function processResult(result) 
    {
    	var newlatlng = { "lat": result.geometry.location.k, "lng": result.geometry.location.D};
    	var address = result.formatted_address;
    	var main_name = address.split("Raleigh")[0].split(",");
    	if (main_name[0].length == 0)
    		return;

    	main_name.pop();
    	var object = {'name': main_name, 'geo': newlatlng, 'isChecked': false};
    	updateMap(object);
    }

    function populateMap(object, startDate, endDate)
    {
    	$.ajax({
	        dataType: "json",
	        url: "./crimes/"+object["geo"]["lat"]+","+object["geo"]["lng"]+","+startDate+","+endDate,
	        success: function(json) {
	            geojson = json["geojson"]
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
					$(locale._icon).addClass('animated fadeIn');
			        locale.bindPopup(prop.desc);
			    });
	        }
	    });
    }

    function updateMap(object)
    {
    	map.setView(object["geo"], 16);

	    var circle = L.circle([object["geo"]["lat"], object["geo"]["lng"]], 5, {
		    color: 'red',
		    fillColor: '#f03',
		    fillOpacity: 0.1
		});

	    animationID = window.setInterval(function() {
		    var rad = circle.getRadius();
		    if (rad<500)
		    	circle.setRadius(rad+5);
		    else
		    	window.clearInterval(animationID);
		}, 5);
	    locations.clearLayers();
	    circleLayer.clearLayers();
	    circle.addTo(circleLayer);
		
	    var startDate = "20150101";
	    var endDate = "20151231";
	    lastSearch = object;
		populateMap(object, startDate, endDate);
		
	    $.ajax({
	        url: "./crimeIndex/"+object["geo"]["lat"]+","+object["geo"]["lng"],
	        dataTye: "json",
	        success: function(json) {
	            crimeIndexRactive.set("crimeIndex", json["crimeRatingYear"][5]);
	            summaryRactive.set("summary", json["crimeRatingYear"]);

	            object["index"] = json["crimeRatingYear"][5];
	            var isSame = recentSearchesRactive.get("hasSearch")(object);
	            if (isSame == false) 
	            	recentSearchesRactive.unshift('searches', object);
	            
	            

	        }
	    });
    }

    searchRactive.on( 'repopulateMap', function(event, startDate, endDate) {
    	populateMap(lastSearch, startDate, endDate);
    });

    searchRactive.on( 'currentLocation', function(event) {
    	if (navigator.geolocation) {
        	navigator.geolocation.getCurrentPosition(function (position) {
        		console.log(position);
        		var output = { "geometry": {"location": {"k": position.coords.latitude, "D": position.coords.longitude}}, "formatted_address": "Your Current Location"};
        		processResult(output);
        	});
	    } else {
	        alert("Your browser does not support GeoLocation");
    	}
    });

    searchRactive.on( 'submitSuggested', function(event, result) {
    	processResult(result);
    });


	searchRactive.on( 'submit', function( event, address )  {
		searchRactive.set('partialMatches', undefined);
	  	geocoder.geocode( { 'address': address, 'componentRestrictions': {'country': 'United States', 'locality': 'Raleigh', 'administrativeArea': 'NC' }}, function(results, status) {
	    if (status == google.maps.GeocoderStatus.OK) {
	      for (var i = 0; i<results.length; i++)
	      {
	      	if (results[i].partial_match == true)
	      	{
	      		//Partial Result
	      		//Not Good Enough
	      		continue;
	      	}
	      	else
	      	{
	      		//Legit Result! 
	      		processResult(results[i]);
	      		return;
	      	}
	      }
	      //Found No Results
	      if (results[0].formatted_address != "Raleigh, NC, USA") {
	      	searchRactive.set('partialMatches', results);
	      }
	      //alert("Unable to find address. Please enter an exact location in Raleigh, NC");
	      $('#searchesModal').modal();
	  	  //
	  	  
	  	  //
	    } else {
	    	$('#searchesModal').modal();
	      //Error Occurred
	      //alert('Geocode was not successful for the following reason: ' + status);
	    }
	  });
	});

	recentSearchesRactive.on( 'select', function( event, object )  {
		updateMap(object);
	});

	map.on('click', function(e) {
		console.log("HELLO");
	});

	recentSearchesRactive.on('dragndrop-items', function (event) {
	  console.log(event);
	});

	

	
    return searchRactive;




});
