/* Fonction js permettant d'ajouter des tabsets
 * 
 * fichier source : 
 * https://stackoverflow.com/questions/35020810/dynamically-creating-tabs-with-plots-in-shiny-without-re-creating-existing-tabs/
 * 
 * */                       
                             

/* Cette fonction permet de : 
 * 1) Ajouter un "li" dans la barre de tabset pour sélectionner un évènement. Chaque li contient un href contenant l'id du contenu
 * 2) Déplacer le contenu (tous les éléments sont créés dynamiquement et placés dans l'id "creationPool_tabpanel") pour le mettre au bon endroit
 * 
 * */
Shiny.addCustomMessageHandler('addTabToTabset', function(message){
	
	console.log("addTabToTabset called");
 
 /* 1) Création du li dans le tabset */ 
 
 console.log("\t création d'un li dans tabsetTarget : " + message.tabsetName);
 var tabsetTarget = document.getElementById(message.tabsetName);
 

 
 
 var event_number = parseInt(message.event_number);
 /* Creating node in the navigation bar */
 var navNode = document.createElement('li');
 var linkNode = document.createElement('a');
 
 linkNode.appendChild(document.createTextNode(event_number)); // le texte : on met le numéro de l'évènement, ce sera renuméroté par une fonction ensuite
 linkNode.setAttribute('data-toggle', 'tab'); // important ! permet de charger le contenu quand on clic sur le "li" 
 linkNode.setAttribute('data-value', 'tabset'+event_number); // utilisé par la fonction de renumérotation des events pour la sélection de chaque tabset 
 linkNode.setAttribute('number', event_number); /* number est utilisé par la fonction de renumérotation des events */
 linkNode.setAttribute('href', '#tab-' + event_number); /* Le lien vers le contenu ; #patients fait référence à tabContent.setAttribute('id', 'patients'); plus bas */
 navNode.appendChild(linkNode);

 /* POSITIONNEMENT DU LI
  *  pour appender le "li" (navNode) : 
  * 	soit le numéro est le plus élevé, on l'append
  * 	soit aucun tabset n'existe encore, l'append 
  * 	soit le numéro n'est pas le plus élevé, on l'insertBefore le plus petit numéro 
  * */

 var tabsets = $("a[data-value^='tabset']") ;
 
 if (tabsets.length==0 || ishighest_number(tabsets, event_number)){
	 tabsetTarget.appendChild(navNode);
 } 
 else {
	 tabsetTarget.insertBefore(navNode, tabsets[0].parentNode);
 }

console.log("\t Renumérotation des tabsets");
renumeroter_tabsets(); // renumérotation des tabsets (texte) 

 
  /* 2) Déplacement du contenu */ 
 /* Move the tabs content to where they are normally stored. Using timeout, because
 it can take some 20-50 millis until the elements are created. */ 
 setTimeout(function(){
	 
	 console.log("\t contenu dans creationPool_tabpanel");
	 var tabContent = document.getElementById('creationPool_tabpanel').childNodes[0]; // Notre contenu à déplacer
	 
	 
	 tabContent.setAttribute('id', 'tab-' + event_number); // ! important ; permet de faire le lien entre le li (via href) et ce contenu
	 
	 /* tabContent doit etre déplacé et mis dans un div "tab-content" ; mais attention il y a plusieurs div "tab-content" si plusieurs tabset panel !! */ 
	 /* on sélectoinne le div de classe "tab-content" qui se situe à coté (sibling) de tabsetTarget qui correspond au tabset panel sélectionné par id plus haut */ 
	 
	 console.log("\t déplacer vers tabContainerTarget");
	 var tabContainerTarget = $(tabsetTarget).siblings(".tab-content")[0];
	 
	 tabContainerTarget.appendChild(tabContent); // contenu appendé !
 }, 200);
 
});




// Cette fonction est la même que addTabToTabset mais customiser pour un tabpanel particulier : Patients                 
 Shiny.addCustomMessageHandler('addPatientsToTabset', function(message){
		/* tabsetpanel où on met va le mettre : */
 var tabsetTarget = document.getElementById(message.tabsetName);

 /* Iterating through all Panel elements : il n'y en a qu'un dans notre cas d'usage*/
 /* Création du 'li' de sélection (node in the navigation bar) */ 
 var navNode = document.createElement('li');
 var linkNode = document.createElement('a');
 
 linkNode.appendChild(document.createTextNode('Patients'));
 linkNode.setAttribute('data-toggle', 'tab');
 linkNode.setAttribute('href', '#patients'); /* Le lien vers le contenu ; #patients fait référence à tabContent.setAttribute('id', 'patients'); plus bas */
 
 navNode.appendChild(linkNode);
 
 tabsetTarget.appendChild(navNode); // ajout du li au tabsetpanel
 
 /* Move the tabs content to where they are normally stored. Using timeout, because
 it can take some 20-50 millis until the elements are created. */ 
 setTimeout(function(){
	 var tabContent = document.getElementById('creationPool_tabpanel').childNodes[0];
	 tabContent.setAttribute('id', 'patients');
	 
	 /* tabContent est déplacé et mis dans un div "tab-content" ; mais attention il y a plusieurs div "tab-content" si plusieurs tabset panel !! */ 
	 /* on sélectoinne le div de classe "tab-content" qui se situe après (sibling) tabsetTarget qu'on sélectionne avec son id */ 
	 var tabContainerTarget = $(tabsetTarget).siblings(".tab-content")[0]
	 tabContainerTarget.appendChild(tabContent);
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
}

/*
 * Pourquoi faut-il renuméroter les tabsets ? Même pb que pour la renumérotation des events pour les tree. Voir moveTree.js - renumeroter_h4_treeboutton() pour les explications"
 *
 * La fonction est appelée lorsqu'on ajoute un "li" au tabset panel
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


