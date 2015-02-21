// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/summaryTemplate', 'crimeIndex'], function ( Ractive, html, crimeIndexRactive) {

    var searchRactive = undefined;
    require(['searchbar'], function( object ){
        searchRactive = object;
    });

    var summaryRactive = new Ractive({
      el: 'summaryDiv',
      template: html,
      data: {
        selectedSummary: undefined,
        selectedYear: 5,
        summary: [],
        hasSummary: function(summary) {
        	return summary.length > 0;
        },
        getIndex: function() {
          var summary = this.get('summary');
          if (summary.length > 0)
            return summary[SelectedYear];
          else 
            return " "
        }
      }
    });

    summaryRactive.on( 'changeYear', function( event, num )  {
      this.set("selectedYear", num);
      var startYear = 2010 + num;
      var endYear = 2010 + num;
      var index = this.get('summary')[num];
      console.log("selected year now ", num);
      searchRactive.fire("repopulateMap", null, startYear+"0101", endYear+"1231");
      crimeIndexRactive.set("crimeIndex", index);
    });

    summaryRactive.observe('summary', function(newValue, oldValue, keypath) {
      this.set('selectedYear', 5);
      console.log("selected year reset to 5");
    });

    return summaryRactive;

});
