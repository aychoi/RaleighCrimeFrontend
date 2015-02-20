// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/summaryTemplate'], function ( Ractive, html) {

    var summaryRactive = new Ractive({
      el: 'summaryDiv',
      template: html,
      data: {
        summary: [],
        hasSummary: function(summary) {
        	return summary.length > 0;
        }
      }
    });

    return summaryRactive;

});
