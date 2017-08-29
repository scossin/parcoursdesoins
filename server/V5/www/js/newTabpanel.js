	/* A Shiny tabsetPanel "mainTabset" looks like this : 
	 * <ul id ="mainTabset">
	 * <div class="tab-content">
	 * 
	 * to add dynamically a new tabset :
	 * 	- add a li node to "mainTabset"
	 *  - add to content to "tab-content"
	 *  
	 *  When li element is clicked, shiny displays the content in tab-content. 
	 *  The link between a li element and a content element (in tab-content) is made by href
	 */


checkNotNull = function(variable, variableName){
	
}
	
	Shiny.addCustomMessageHandler('newTabpanel', function(message){
		
		console.log("newTabpanel shiny function called");
	 
	 // check arguments : 
	 
	 var tabsetPanel = message.tabsetPanel;
	 var liText = message.liText; // the text to display in the li element
	 var contentId = message.contentId;
	 
	 if (tabsetPanel == null){
		 console.error("\t empty argument tabsetPanel");
		 return;
	 }
	 
	 if (liText == null){
		 console.error("\t empty argument liText");
		 return;
	 }
	 
	 if (contentId == null){
		 console.error("\t empty argument liText");
		 return;
	 }
	 
	 /* 1) Create a new li node in the tabset */ 
	 
	 console.log("\t Trying to create a new li element in the tabsetPanel : " + tabsetPanel);
	 var mainTabset = document.getElementById(tabsetPanel);
	 if (mainTabset == null){
		 console.error(tabsetPanel + "\t not found in the DOM ");
		 return;
	 }
	 
	 var navNode = document.createElement('li');
	 var linkNode = document.createElement('a');
	 
	 linkNode.appendChild(document.createTextNode(liText)); // text of the tabPanel
	 linkNode.setAttribute('data-toggle', 'tab'); // important ! shiny will display the content when we click on the li node 
	 
	 // caution ! no check contentId already exists are not
	 // var newDivContentId = 'tab-' + contentId;
	 var newDivContentId = contentId;
	 
	 linkNode.setAttribute('href', "#"+newDivContentId); /* Link between this li node dans the content see below */
	 //linkNode.setAttribute('data-value', liText);
	 navNode.appendChild(linkNode);
	 mainTabset.appendChild(navNode);
	 
	 console.log("\t A new li element in the tabsetPanel : " + tabsetPanel + " has been added");
	 
	 
	 /* 2) A content a new li node in the tabset */ 
	     console.log("\t Creating basic content ...");
	 	 var tabContentContainer = $(mainTabset).siblings(".tab-content")[0]; // caution ! other ".tab-content" may exist. Select the sibiling of the tabsetPanel
		 var newDivContent = document.createElement('div');
		 newDivContent.setAttribute('id', newDivContentId); // ! important ; link between li node and the content for Shiny
		 newDivContent.setAttribute('class', 'tab-pane'); // ! important ; Shiny must know this content is of class tab-pane
		 tabContentContainer.appendChild(newDivContent);
		 
		 // add basic content now : an empty div with an id where UI will be appended by the application
		 var newContent = document.createElement('div');
		 newContent.setAttribute('id', 'firstDivOf' + contentId);
		 newDivContent.appendChild(newContent);
		 console.log("\t newTabpanel finished !");
	});
