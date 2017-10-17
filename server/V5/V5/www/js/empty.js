Shiny.addCustomMessageHandler('empty', function(message){
	    var objectId = $("#" + message.objectId);
	    console.log("Trying to empty " + message.objectId);
	    objectId.empty();
});
