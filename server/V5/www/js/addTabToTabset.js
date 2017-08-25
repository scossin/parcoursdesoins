	Shiny.addCustomMessageHandler('addTabToTabset', function(message){
		
		console.log("addTabToTabset called");
	 
	 /* 1) Create a new li node in the tabset */ 
	 
	 console.log("\t Creating a new li element in the tabset : " + message.tabsetName);
	 var tabsetTarget = document.getElementById(message.tabsetName);
	 
	 var eventNumber = parseInt(message.eventNumber);
	 var navNode = document.createElement('li');
	 var linkNode = document.createElement('a');
	 
	 linkNode.appendChild(document.createTextNode(eventNumber)); // node text is eventNumber
	 linkNode.setAttribute('data-toggle', 'tab'); // important ! shiny will display the content when we click on the li node 
	 linkNode.setAttribute('data-value', 'tabset'+eventNumber); // use to numerotate the events
	 linkNode.setAttribute('number', eventNumber); // use to numerotate the events
	 linkNode.setAttribute('href', '#tab-' + eventNumber); /* Link between this li node dans the content : see below tabContent.setAttribute('id', 'patients') */
	 navNode.appendChild(linkNode);
	
	 /* Where to append the li node 
	  *     highest number : append
	  * 	only one : append
	  * 	not the hight : insertBefore 
	  * */
	
	 var tabsets = $("a[data-value^='tabset']") ;
	 
	 if (tabsets.length==0 || ishighest_number(tabsets, eventNumber)){
		 tabsetTarget.appendChild(navNode);
	 } 
	 else {
		 tabsetTarget.insertBefore(navNode, tabsets[0].parentNode);
	 }
	
	// console.log("\t numerotate events");
	// renumeroter_tabsets(); // renumérotation des tabsets (texte) 
	
	 
	  /* 2) Move content */ 
	 /* Move the tabs content to where they are normally stored. Using timeout, because
	 it can take some 20-50 millis until the elements are created. */ 
	 setTimeout(function(){
		 
		 console.log("\t content in tabpanelPool");
		 var tabContent = document.getElementById('tabpanelPool').childNodes[0]; // the content
		 
		 
		 tabContent.setAttribute('id', 'tab-' + eventNumber); // ! important ; link between li node and this content for Shiny
		 
		 /* Caution ! tabContent must now move to a "tab-content" div but many may exist if many tabsetpanel exist */ 
		 /* Select div "tab-content" next to tabsetTarget */ 
		 
		 console.log("\t moving content ...");
		 var tabContainerTarget = $(tabsetTarget).siblings(".tab-content")[0];
		 
		 tabContainerTarget.appendChild(tabContent); // content appended ! !
	 }, 200);
	 
	});
	
	
	// fonction pour positionner le "li" pour la fonction addTabToTabset
	ishighest_number = function(tabsets, number){
		var valeurs = [];
		
		for(var i = 0; i < tabsets.length; i++){
			tabsets[i].getAttribute("number") ; // valeur : "0"
			valeur = parseInt(valeur); // valeur : 0
			valeurs.push(valeur);
		}
		for (var i = 0; i < valeurs.length;i++){
			if (valeurs[i] > number){
				return(false); // dès qu'on trouve un nombre supérieur on renvoie false
			}
		}
		
		return(true); // si aucun "number" de tabsets a une valeur supérieur à celui-ci, on renvoie false
	};
	
	
	/* PATCH to a bug with sunburst
	 * can't figure why there are 2 id="sunburstid-trail" in div class="sunburst-sequence". Removing the first one resolves the problem
	 */
	Shiny.addCustomMessageHandler('removeSunburstTrail', function(message){
		console.log("removing SunburstTrail");
		setTimeout(function(){
			 var SunburstTrailId = message.id;
			document.getElementById(SunburstTrailId).remove();
	}, 900);
	});
	
