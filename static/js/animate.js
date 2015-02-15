// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/template', "jquery", "velocity"], function ( Ractive, html, jquery, velocity) {

	//alert('test');

    setInterval(function() {
      $("#searchContainer").velocity("callout.shake");
    }, 2000);

});
