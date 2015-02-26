// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/recentSearchesTemplate'], function ( Ractive, html) {



    var recentSearchesRactive = new Ractive({
      el: 'addresses',
      template: html,
      data: {
        searches: [],
        exported: [],
        findColor: function(index) {
        	if (index >=85)
        		return "red";
        	if (index <= 35)
        		return "green";
        	return "orange";
        },
        formattedCrimeIndex: function (crimeIndex) {
            //return (crimeIndex).toFixed(2);
            return Math.round(crimeIndex);
        },
        hasSearch: function(object) {
          var x;
          var searches = recentSearchesRactive.get('searches');
          var isSame = false;
          for (x in searches) {
            var rs = searches[x];
            if (rs["name"][0] == object["name"][0]) {
              isSame = true;
            }
          }
          return isSame;
        }
      }
    });


    recentSearchesRactive.on( 'export', function( event, exported )  {
      var searchQuery = "./";
      for (index in exported) {
        searchQuery+=exported[index].name[0]+","+exported[index].geo.lat+","+exported[index].geo.lng+",";
      }
      var win = window.open(searchQuery, '_blank');
      //var win = window.open("http://anylytics.io/raleighcrime/35.8082629,-78.64130499999999,35.794904,-78.649558,35.840196,-78.666232", '_blank');
    });

    recentSearchesRactive.on( 'addToExport', function( event, object )  {
      /*recentSearchesRactive.unshift('exported', object).then(function() {
        console.log(recentSearchesRactive.get('exported'));
      });*/
      
      //exported.unshift(object);
      if (object.isChecked == false) {
        var exported = recentSearchesRactive.get('exported');
        var index = exported.indexOf(object);
        recentSearchesRactive.splice("exported", index, 1);
        console.log(recentSearchesRactive.get('exported'));
      }
      else {
        recentSearchesRactive.unshift("exported", object).then( function() {
          var exported = recentSearchesRactive.get('exported');
          if (exported.length > 3) {
            recentSearchesRactive.pop("exported").then( function (pop) {
              var searches = recentSearchesRactive.get("searches");
              var index = searches.indexOf(pop);
              recentSearchesRactive.set("searches["+index+"].isChecked", false);
              //searches[index].isChecked = false;
              console.log(searches[index]);
            }); 
          }
          console.log(recentSearchesRactive.get('exported'));
        });
      }
      
      

    });

    /*recentSearchesRactive.observe('exported', function(newValue, oldValue, keypath) {
        if (newValue.length > 3) {
          recentSearchesRactive.pop('exported');
        }
    });*/


    return recentSearchesRactive;

});
