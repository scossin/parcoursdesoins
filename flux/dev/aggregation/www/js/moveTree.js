


Shiny.addCustomMessageHandler('moveTree', function(message){
/* pour retirer le contenu (le div) du tabset */

setTimeout(function(){
var divtarget = document.getElementById(message.divtargetname);

var treeboutton = document.getElementById(message.treebouttonid);

if (message.boolprevious == null){
	divtarget.appendChild(treeboutton);
} else {
	divtarget.prepend(treeboutton);
}
//

}, 100);

// Afficher le tree
//var bouttonafficher = document.getElementById(message.bouttonafficher);
//bouttonafficher.click()
});	


/*
setTimeout(function(){
//alert("re-ordering now !! ");
var $divs = $("div.box");
var valuesort = $divs.sort(function (a, b) {     return $(a).attr("value") > $(b).attr("value"); });
if ($divs.length > 1){
	$("#alltrees").html(valuesort);
}
bouttonafficher.click();
}, 100);
*/



/* Test : 
 * 
 * message = [];
message.divtargetname = "alltrees"
var divtarget = document.getElementById(message.divtargetname);
message.elementname = "treeboutton10";
var element = document.getElementById(message.elementname);
divtarget.appendChild(element);
 * 
 * 
 * */

/* L'objectif de la fonction remove_treebutton est de retirer tous les div "treebutton" qui précède ou qui suit un treebutton
 * Comme tous les évènements qui suivent ( ou précédent) un évènement sont dépendants de ce dernier, s'il change alors tous les autres doivent changer en cascade 
 * C'est pourquoi on les retire tous et l'utilisateur devra re-définir ce qu'il veut voir */
Shiny.addCustomMessageHandler('remove_treebutton', function(message){
	value = parseInt(message.value); // value : numéro du div stocké dans l'attribut value du div
	if (message.itself == null){ // faut-il retirer aussi le div de l'évènement lui-meme : oui pour le boutton remove, non pour le boutton validate
		boolitself = false;
	} else {
		boolitself = true;
	}
	
	var $divs = $("div.box");
	
	// Si value = 0 (le MainEvent), on retire tous les div :
	if (value == 0) {
		for(var i = 0; i < $divs.length; i++){
			valeur = $divs[i].getAttribute("value");
			if (valeur == 0) { // mainEvent : on ne l'enlève pas  
					continue ;
							}
			$divs[i].remove();
		}
		
		return null ;
	} // fin cas value = 0
	
	// cas ou value est positif : retirer tous ce qui est après
	if (value > 0) {
		for(var i = 0; i < $divs.length; i++){
			valeur = $divs[i].getAttribute("value");
			if (valeur > value) { 
			   $divs[i].remove();
			}
		}
		if (boolitself){
			$divs[value].remove()
		}
		return null ;
	} // fin cas value > 0
	
	if (value < 0) {
		for(var i = 0; i < $divs.length; i++){
			valeur = $divs[i].getAttribute("value");
			if (valeur < value) { 
			   $divs[i].remove();
			}
		}
		
		if (boolitself){
			$divs[value].remove()
		}
		return null ;
	} // fin cas value < 0
	});


Shiny.addCustomMessageHandler('remove_treebutton', function(message){
	value = parseInt(message.value); // value : numéro du div stocké dans l'attribut value du div
	var $divs = $("div.box");
	for(var i = 0; i < $divs.length; i++){
		valeur = $divs[i].getAttribute("value");
		if (valeur == value) { 
		   	$divs[i].remove();
		}
	}
});

// $divs[0].children[0].textContent = "event-3"
