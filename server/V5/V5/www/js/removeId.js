	Shiny.addCustomMessageHandler('removeId', function(message){
		setTimeout(function(){
			var objectId = $("#"+message.objectId);
			console.log("Trying to remove " + objectId);
			if (objectId == null){
				console.log("\t" + objectId + "not found in DOM");
			} else {
				objectId.hide(1000, function(){ 
					objectId.remove();
					console.log("\t" + objectId + "removed");
				});
			}
		}, 1000);
});
	
