// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/searchbarTemplate'], function ( Ractive, html) {

    var searchRactive = new Ractive({
      el: 'searchContainer',
      template: html,
      data: {
        searchquery: ""
      }
    });

    searchRactive.observe('searchquery', function(newValue, oldValue, keypath) {
    	console.log(newValue);
    });

    return searchRactive;

});
