/* Fonction js permettant d'ajouter des tabsets
 * 
 * fichier source : 
 * https://stackoverflow.com/questions/35020810/dynamically-creating-tabs-with-plots-in-shiny-without-re-creating-existing-tabs/
 * 
 * */


/* In coherence with the original Shiny way, tab names are created with random numbers. 
                             To avoid duplicate IDs, we collect all generated IDs.  */
                             // var hrefCollection = []; pas besoin !
                             
                             Shiny.addCustomMessageHandler('addTabToTabset', function(message){
                             
                             tabsetName = parseInt(message.tabsetNumber)
                             
                             var hrefCodes = [];
                             /* Getting the right tabsetPanel */
                             var tabsetTarget = document.getElementById(message.tabsetName);
                             
                             /* Iterating through all Panel elements */
                             for(var i = 0; i < message.titles.length; i++){
                             
                             /* Creating 6-digit tab ID and check, whether it was already assigned. */

/* je ne comprends pas sa boucle do while inside for loop : je retire */ 
/* do {
hrefCodes[i] = Math.floor(Math.random()*100000);
} 
while(hrefCollection.indexOf(hrefCodes[i]) != -1); */

 /* je remplace l id par le titre au lieu d un nombre aleatoire (voir plus haut) */
                             hrefCodes[i] = message.titles[i];
                             
                             //hrefCollection = hrefCollection.concat(hrefCodes[i]);
                             
                             /* Creating node in the navigation bar */
                             var navNode = document.createElement('li');
                             var linkNode = document.createElement('a');
                             
                             linkNode.appendChild(document.createTextNode(message.titles[i]));
                             linkNode.setAttribute('data-toggle', 'tab');
                             linkNode.setAttribute('data-value', 'tabset'+message.titles[i]);
                             linkNode.setAttribute('number', message.titles[i]);
                             linkNode.setAttribute('href', '#tab-' + hrefCodes[i]);
                             
                             navNode.appendChild(linkNode);
                             
                             
                             /*
                              *  pour appender navNode : 
                              * 	soit le numéro est le plus élevé, on l'append
                              * 	soit aucun tabset n'existe encore, l'append 
                              * 	soit le numéro n'est pas le plus élevé, on l'insertBefore le plus petit numéro */

                             number = parseInt(message.titles[i]);
                             var tabsets = $("a[data-value^='tabset']") ;
                             if (tabsets.length==0 || ishighest_number(tabsets, number)){
								 tabsetTarget.appendChild(navNode);
							 } 
							 else {
								 tabsetTarget.insertBefore(navNode, tabsets[0].parentNode);
							 }

                             };
                             
                             /* Move the tabs content to where they are normally stored. Using timeout, because
                             it can take some 20-50 millis until the elements are created. */ 
                             setTimeout(function(){
                             var creationPool = document.getElementById('creationPool').childNodes;
                             var tabContainerTarget = document.getElementsByClassName('tab-content')[0];
                             
                             /* Again iterate through all Panels. */
                             for(var i = 0; i < creationPool.length; i++){
                             var tabContent = creationPool[i];
                             tabContent.setAttribute('id', 'tab-' + hrefCodes[i]);
                             tabContainerTarget.appendChild(tabContent);
                             };
                             }, 100);
                             renumeroter_tabsets();
                             });

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
	
	return(true); // si aucun "number" de tabset à une valeur a celui qu'on ajoute
}

/*
 * Pourquoi faut-il renuméroter les tabsets ? Même pb que pour la renumérotation des events. Voir moveTree.js - renumeroter_h4_treeboutton() pour les explications"
 * */
renumeroter_tabsets = function(){
	 // Identifier les tabsets dans le dom
var tabsets = $("a[data-value^='tabset']")

 // On compte combien ont un id négatif
var negatif = 0;
for(var i = 0; i < tabsets.length; i++){
	var valeur = tabsets[i].getAttribute("number") ; // valeur : "0"
	valeur = parseInt(valeur); // valeur : 0	
	if (valeur < 0) negatif += 1
}

	// On renumérote
for(var i = 0; i < tabsets.length; i++){
	n = i - negatif ;
	tabsets[i].textContent = "event" + n ;
}
}


// onclick précédent
precedent = function(){
	var timelines = $("[data-value=Timelines]");
	timelines[0].click();
	var events = $("[data-value=Events]");
	events[0].click();
};


