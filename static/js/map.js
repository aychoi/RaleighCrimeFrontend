// Now we've configured RequireJS, we can load our dependencies and start

define(['mapbox'], function (mapbox){

    var light_tiles = {
        "tiles": [ "https://a.tiles.mapbox.com/v3/examples.map-20v6611k/{z}/{x}/{y}@2x.png" ],
        "minzoom": 0,
        "maxzoom": 18
    }

    var dark_tiles = {
        "tiles": [ "https://b.tiles.mapbox.com/v3/examples.map-cnkhv76j/{z}/{x}/{y}@2x.png" ],
        "minzoom": 0,
        "maxzoom": 18
    }

    L.mapbox.accessToken = 'pk.eyJ1IjoiZ3VpbHR5c3BhcmsiLCJhIjoiSHFCN3dORSJ9.FEKH5Kb6J5aK7ezNtn9BeQ';
    var map = L.mapbox.map('map', "guiltyspark.kl48ij2n", { zoomControl: false })
    .setView([35.786090, -78.663556], 13);

    new L.Control.Zoom({ position: 'bottomleft' }).addTo(map);

    return map;
});
