// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/summaryTemplate', 'crimeIndex', 'jquery', 'velocity'], function ( Ractive, html, crimeIndexRactive, $, Velocity) {

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
      
    });



    var summaryPlacememt = 0;
    var summarydivs = document.querySelectorAll("#summary");

    summaryRactive.on( 'moveSummary', function( event, num ) {
      if (summaryPlacememt == 0) {
            Velocity(document.querySelectorAll("#summary"), { translateY: "+=185" }, 300);
            document.getElementById('hideSummary').style.visibility="visible";
            summaryPlacememt = 1;
        } else if (summaryPlacememt == 1) {
            Velocity(document.querySelectorAll("#summary"), { translateY: "-=185" }, 300);
            document.getElementById('hideSummary').style.visibility="visible";
            summaryPlacememt = 0;
        }
    });

    return summaryRactive;

});
