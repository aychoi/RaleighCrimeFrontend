// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/recentSearchesTemplate'], function ( Ractive, html) {



    var recentSearchesRactive = new Ractive({
      el: 'addresses',
      template: html,
      data: {
        searches: [],
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




    return recentSearchesRactive;

});
