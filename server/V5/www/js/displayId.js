Shiny.addCustomMessageHandler('displayShowId', function(message){
		setTimeout(function(){
			var objectId = $("#" + message.objectId);
			console.log("Trying to show " + message.objectId);
			if (objectId == null){
				console.log("\t" + message.objectId + "not found in DOM");
			} else {
				objectId.show(1000, function(){ 
					console.log("\t" + message.objectId + " shown");
				});
			}
		},100);
});

Shiny.addCustomMessageHandler('displayHideId', function(message){
		 setTimeout(function(){
			var objectId = $("#" + message.objectId);
			console.log("Trying to hide " + message.objectId);
			if (objectId == null){
				console.log("\t" + message.objectId + "not found in DOM");
			} else {
				objectId.hide(1000, function(){ 
					console.log("\t" + message.objectId + " hidden");
				});
			}
		},100);
});
