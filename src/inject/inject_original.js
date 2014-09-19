chrome.extension.sendMessage({}, function(response) {
	var readyStateCheckInterval = setInterval(function() {
	if (document.readyState === "complete") {
		clearInterval(readyStateCheckInterval);

		// ----------------------------------------------------------
		// This part of the script triggers when page is done loading
		console.log("Hello. This message was sent from scripts/inject.js");

		// ----------------------------------------------------------
		$('<div class="hrguessform"> First name:<input type="text" name="name" class="em_name"><span hint="0" class="an_name"></span><br> Title: <input type="text" name="title" class="em_title"><span class="an_title"></span> </div>').insertBefore($('.basics'));
		console.log("Hello. This happened");
		var clicked

		$( ".em_name" ).keyup(function (e) {
    	if (e.keyCode == 13) {
    		var nameArray = $(this).val().split('');
    		var nameRegex = "^.?";
    		for (letInd in nameArray) {
    			nameRegex+=(nameArray[letInd]+".?")
    		}
    		nameRegex+="$";
    		nameRegex = new RegExp(nameRegex)
    		var firstname = $(this).parent().next(".basics").children("dt").text().split(",")[1].trim();


    		console.log(nameRegex)
    		
    		console.log("pressed enter in the em name box");

    		console.log("the text is " + firstname)

    		if (firstname.search(nameRegex) != -1) {
    			console.log("Correct the name is " + firstname);
    			$(this).next('.an_name').text("Correct the name is "+ firstname)
    		} else {
    			answer = $(this).next('.an_name')
    			hintlevel = parseInt(answer.attr('hint')) + 1;
    			answer.fadeOut(1000).fadeIn(1000).text("Incorrect, but here's a hint: " + firstname.substring(0,hintlevel))
    			answer.attr('hint', hintlevel.toString())

    		}







    		//console.log(nameEntered);



			// if ( $( "input:first" ).val() === "correct" ) {
			//     //$( "span" ).text( "Validated..." ).show();
			//     return;
			// }
			//   $( "span" ).text( "Not valid!" ).show().fadeOut( 1000 );
			//   event.preventDefault();
		}
		});

	}
	}, 10);
});