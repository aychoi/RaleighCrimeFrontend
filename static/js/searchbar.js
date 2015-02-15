// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/template'], function ( Ractive, html) {



    var searchRactive = new Ractive({
      el: 'searchContainer',
      template: html,
      data: {
        greeting: "Hello, World"
      }
    });

    return sampleRactive;

});
