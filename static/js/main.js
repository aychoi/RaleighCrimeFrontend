// First we have to configure RequireJS
require.config({
    // This tells RequireJS where to find Ractive and rvc
    paths: {
        ractive: 'lib/ractive',
        rv: 'loaders/rv',
        mapbox: 'lib/mapbox',
        jquery: 'lib/jquery-1.11',
        jqueryui: 'lib/jquery_ui',
        velocity: 'lib/velocity.min',
        ractive_events_keys: 'lib/ractive-events-keys.min',
        async: 'lib/async'
    }
});


require(["map", "searchbar", "animate"]);