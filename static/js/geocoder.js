// Now we've configured RequireJS, we can load our dependencies and start
define(['async!https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=true'], function (  ) {

  var geocoder;
  
  geocoder = new google.maps.Geocoder();
  return geocoder

});
