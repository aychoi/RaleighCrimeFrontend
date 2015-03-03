// Now we've configured RequireJS, we can load our dependencies and start
define([ 'ractive', 'rv!../ractive/crimeIndexTemplate', 'jquery', 'velocity', 'bootstrap'], function ( Ractive, html, $, Velocity, bootstrap) {

    var crimeIndexRactive = new Ractive({
      el: 'crimeIndexDiv',
      template: html,
      data: {
        crimeIndex: " ",
        formattedCrimeIndex: function (crimeIndex) {
            //return (crimeIndex).toFixed(2);
            return Math.round(crimeIndex);
        },
        isNextLine: function (i) {
            if (i==2 || i==4) return true
            return false
        },
        filters: ["Driving", "Drugs/Alcohol", "Theft/Burglary", "Property Damage", "Violent Crimes", "Sexual Offense", "Miscellaneous"]
      }
    });


    /*   Cookies   */

    function getCookie(cname) {
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for(var i=0; i<ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0)==' ') c = c.substring(1);
            if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
        }
        return "";
    }

    var firstTime = getCookie("visited");;

    if (firstTime==false) {
        $('#explainModal').modal('show');
    }
    document.cookie="visited=true";

    crimeIndexRactive.set('selectedFilters', crimeIndexRactive.get('filters'));

    var datePlacement = 0;
    var crimePlacement = 0;
    var legendPlacement = 0;
    var legenddivs = document.querySelectorAll("#legend");
    var datedivs = document.querySelectorAll("#filterDates");
    var crimedivs = document.querySelectorAll("#filterCrimes");

    crimeIndexRactive.on( 'moveLegend', function( event, object )  {
        if (legendPlacement == 0) {
            Velocity(document.querySelectorAll("#legend"), { translateX: "+=365" }, 300);
            document.getElementById('closeFilterLegend').style.visibility="visible";
            document.getElementById('openFilterLegend').style.visibility="hidden";
            $("#legendTrigger img").addClass("iconImgActive");
            legendPlacement = 1;
        } else if (legendPlacement == 1) {
            Velocity(document.querySelectorAll("#legend"), { translateX: "-=365" }, 300);
            document.getElementById('closeFilterLegend').style.visibility="hidden";
            document.getElementById('openFilterLegend').style.visibility="visible";
            $("#legendTrigger img").removeClass("iconImgActive");
            legendPlacement = 0;
        }
    });

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
                $("#dates").removeClass("iconImgActive");
            }
            crimePlacement = 1;
            Velocity(crimedivs, { translateY: "+=450" }, 300); // Velocity
            $("#crimes img").addClass("iconImgActive");
        }
        else if (crimePlacement==1) {
	        Velocity(crimedivs, { translateY: "-=450" }, 300); // Velocity
	        crimePlacement = 0;
          $("#crimes img").removeClass("iconImgActive");
        }
	});


    return crimeIndexRactive;

});
