// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/crimeIndexTemplate', 'jquery', 'velocity'], function ( Ractive, html, $, Velocity) {


    var crimeIndexRactive = new Ractive({
      el: 'crimeIndexDiv',
      template: html,
      data: {
        crimeIndex: " ",
        formattedCrimeIndex: function (crimeIndex) {
            //return (crimeIndex).toFixed(2);
            return Math.round(crimeIndex);
        }
      }
    });

    var datePlacement = 0;
    var crimePlacement = 0;
    var datedivs = document.querySelectorAll("#filterDates");
    var crimedivs = document.querySelectorAll("#filterCrimes");

    crimeIndexRactive.on( 'bringDownDate', function( event, object )  {
    	    /* Animate all divs at once. */
        if (datePlacement==0) {
            if (crimePlacement==1) {
                crimePlacement=0;
                Velocity(crimedivs, { translateY: "-=80" }, 300); // Velocity
                document.getElementById('crimes').style.color="skyblue";
                document.getElementById('crimes').style.backgroundColor="white";
            }
            datePlacement = 1;
            Velocity(datedivs, { translateY: "+=51" }, 300); // Velocity
            document.getElementById('dates').style.color="white";
            document.getElementById('dates').style.backgroundColor="skyblue";
        } 
        else if (datePlacement==1) {
                Velocity(datedivs, { translateY: "-=51" }, 300); // Velocity
                datePlacement = 0;
                document.getElementById('dates').style.color="skyblue";
                document.getElementById('dates').style.backgroundColor="white";
        }
    });

	crimeIndexRactive.on( 'bringDownCrime', function( event, object )  {
		 /* Animate all divs at once. */
        if (crimePlacement==0) {
            if (datePlacement==1) {
                datePlacement=0;
                Velocity(datedivs, { translateY: "-=51" }, 300); // Velocity
                document.getElementById('dates').style.color="skyblue";
                document.getElementById('dates').style.backgroundColor="white";
            }
            crimePlacement = 1;
            Velocity(crimedivs, { translateY: "+=80" }, 300); // Velocity
            document.getElementById('crimes').style.color="white";
            document.getElementById('crimes').style.backgroundColor="skyblue";
        } 
        else if (crimePlacement==1) {
	        Velocity(crimedivs, { translateY: "-=80" }, 300); // Velocity
	        crimePlacement = 0;
	        document.getElementById('crimes').style.color="skyblue";
	        document.getElementById('crimes').style.backgroundColor="white";
        }
	});
	

    return crimeIndexRactive;

});
