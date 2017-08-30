Shiny.addCustomMessageHandler('goFirstSibling', function(message){
			var objectId = $("#" + message.objectId);
			console.log("Trying to make " + message.objectId + " first");
			if (objectId == null){
				console.log("\t" + message.objectId + " not found in DOM");
				return;
			} else if (objectId.siblings.length == 0) {
				console.log("\t" + message.objectId + " has no sibling");
				return;
			} else {
				objectId.hide(50);
				sibling = objectId.siblings()[0];
				objectId.insertBefore(sibling);
				objectId.show(50);
			}
});
